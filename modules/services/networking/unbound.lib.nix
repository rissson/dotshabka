{ mode, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.unbound;


  yesOrNo = v: if v then "yes" else "no";

  toOption = indent: n: v: "${indent}${toString n}: ${v}";

  toConf = indent: n: v:
    if builtins.isFloat v then (toOption indent n (builtins.toJSON v))
    else if isInt v       then (toOption indent n (toString v))
    else if isBool v      then (toOption indent n (yesOrNo v))
    else if isString v    then (toOption indent n v)
    else if isList v      then (concatMapStringsSep "\n" (toConf indent n) v)
    else if isAttrs v     then (concatStringsSep "\n" (
                                  ["${indent}${n}:"] ++ (
                                    mapAttrsToList (toConf "${indent}  ") v
                                  )
                                ))
    else throw (traceSeq v "services.unbound.settings: : unexpected type");


  confFile = pkgs.writeText "unbound.conf" (concatStringsSep "\n" ((mapAttrsToList (toConf "") cfg.settings) ++ [""]));

  rootTrustAnchorFile = "${cfg.stateDir}/root.key";

in {

  ###### interface

  options = {
    services.unbound = {

      enable = mkEnableOption "Unbound domain name server";

      package = mkOption {
        type = types.package;
        default = pkgs.unbound;
        defaultText = "pkgs.unbound";
        description = "The unbound package to use";
      };

      user = mkOption {
        type = types.str;
        default = "unbound";
        description = "User account under which unbound runs.";
      };

      stateDir = mkOption {
        default = "/var/lib/unbound";
        description = "Directory holding all state for unbound to run.";
      };

      resolveLocalQueries = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether unbound should resolve local queries (i.e. add 127.0.0.1 to
          /etc/resolv.conf).
        '';
      };

      enableRootTrustAnchor = mkOption {
        default = true;
        type = types.bool;
        description = "Use and update root trust anchor for DNSSEC validation.";
      };

      settings = mkOption {
        default = {};
        type = with types; submodule {

          freeformType = let
            validSettingsPrimitiveTypes = oneOf [ int str bool float ];
            validSettingsTypes = oneOf [ validSettingsPrimitiveTypes (listOf validSettingsPrimitiveTypes) ];
            settingsType = (attrsOf validSettingsTypes);
          in attrsOf (oneOf [ settingsType (listOf settingsType) ])
              // { description = ''
                unbound.conf configuration type. The format consist of an attribute
                set of settings. Each settings can be either one value, a list of
                values or an attribute set. The allowed values are integers,
                strings, booleans or floats.
              '';
            };

          options = {
            remote-control.control-enable = mkOption {
              type = bool;
              default = false;
              description = "";
            };
          };
       };
        example = literalExample ''
          {
            server = {
              interface = [ "127.0.0.1" ];
            };
            forward-zone = [
              {
                name = ".";
                forward-addr = "1.1.1.1@853#cloudflare-dns.com";
              }
              {
                name = "example.org.";
                forward-addr = [
                  "1.1.1.1@853#cloudflare-dns.com"
                  "1.0.0.1@853#cloudflare-dns.com"
                ];
              }
            ];
            remote-control.control-enable = true;
          };
        '';
        description = ''
          Declarative Unbound configuration
          See the <citerefentry><refentrytitle>unbound.conf</refentrytitle>
          <manvolnum>5</manvolnum></citerefentry> manpage for a list of
          available options.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge (singleton (optionalAttrs (mode == "NixOS") {

    services.unbound.settings = {
      server = {
        directory = mkDefault cfg.stateDir;
        username = cfg.user;
        chroot = cfg.stateDir;
        pidfile = ''""'';
        interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        access-control = mkDefault ([ "127.0.0.0/8 allow" ] ++ (optional config.networking.enableIPv6 "::1/128 allow"));
        auto-trust-anchor-file = mkIf cfg.enableRootTrustAnchor rootTrustAnchorFile;
        tls-cert-bundle = mkDefault "/etc/ssl/certs/ca-certificates.crt";
      };
      remote-control = {
        control-enable = mkDefault false;
        control-interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        server-key-file = mkDefault "${cfg.stateDir}/unbound_server.key";
        server-cert-file = mkDefault "${cfg.stateDir}/unbound_server.pem";
        control-key-file = mkDefault "${cfg.stateDir}/unbound_control.key";
        control-cert-file = mkDefault "${cfg.stateDir}/unbound_control.pem";
      };
    };

    environment.systemPackages = [ cfg.package ];

    users.users = mkIf (cfg.user == "unbound") {
      unbound = {
        description = "unbound daemon user";
        isSystemUser = true;
      };
    };

    networking = mkIf cfg.resolveLocalQueries {
      nameservers = optional cfg.resolveLocalQueries "127.0.0.1";

      resolvconf = mkIf cfg.resolveLocalQueries {
        useLocalResolver = mkDefault true;
      };

      networkmanager.dns = "unbound";
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0755 ${cfg.user} nogroup - -"
      "d '${cfg.stateDir}/dev' 0755 ${cfg.user} nogroup - -"
      "Z '${cfg.stateDir}' - ${cfg.user} nogroup - -"
    ];

    systemd.services.unbound = {
      description = "Unbound recursive Domain Name Server";
      after = [ "network.target" ];
      before = [ "nss-lookup.target" ];
      wants = [ "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];

      path = mkIf cfg.settings.remote-control.control-enable [ pkgs.openssl ];

      preStart = ''
        ${optionalString cfg.enableRootTrustAnchor ''
          ${cfg.package}/bin/unbound-anchor -a ${rootTrustAnchorFile} || echo "Root anchor updated!"
          chown unbound ${cfg.stateDir} ${rootTrustAnchorFile}
        ''}
        touch ${cfg.stateDir}/dev/random
        ${pkgs.utillinux}/bin/mount --bind -n /dev/urandom ${cfg.stateDir}/dev/random
        ${optionalString cfg.settings.remote-control.control-enable ''
          ${cfg.package}/bin/unbound-control-setup -d ${cfg.stateDir}
        ''}
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/unbound -d -c ${confFile}";
        ExecStopPost = "${pkgs.utillinux}/bin/umount ${cfg.stateDir}/dev/random";

        ProtectSystem = true;
        ProtectHome = true;
        PrivateDevices = true;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  })));

  imports = [
    (mkRenamedOptionModule [ "services" "unbound" "interfaces" ] [ "services" "unbound" "settings" "server" "interface" ])
    (mkChangedOptionModule [ "services" "unbound" "allowedAccess" ] [ "services" "unbound" "settings" "server" "access-control" ] (
      config: map (value: "${value} allow") (getAttrFromPath [ "services" "unbound" "allowedAccess" ] config)
    ))
    (mkRemovedOptionModule [ "services" "unbound" "forwardAddresses" ] ''
      Add a new setting:
      services.unbound.settings.forward-zone = [{
        name = ".";
        forward-addr = [ # Your current services.unbound.forwardAddresses ];
      }];
      If any of those addresses are local addresses (127.0.0.1 or ::1), you must
      also set services.unbound.settings.server.do-not-query-localhost to false.
    '')
    (mkRemovedOptionModule [ "services" "unbound" "extraConfig" ] ''
      You can use services.unbound.settings to add any configuration you want.
    '')
  ];
}
