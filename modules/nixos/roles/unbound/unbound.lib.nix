{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.unbound;

  settingsSubmodule = let
    validConfigTypes = with types; either int (either str (either bool float));
  in {
    options = {
      server = mkOption {
        type = with types; attrsOf (nullOr (either validConfigTypes (listOf validConfigTypes)));
        default = { };
        description = "server: clause configuration";
      };
      remote-control = mkOption {
        type = with types; attrsOf (nullOr (either validConfigTypes (listOf validConfigTypes)));
        default = { };
        description = "remote-control: clause configuration";
      };
      stub-zone = mkOption {
        type = with types; listOf (attrsOf (nullOr (either validConfigTypes (listOf validConfigTypes))));
        default = [ ];
        description = "stub-zone: clause configuration";
      };
      forward-zone = mkOption {
        type = with types; listOf (attrsOf (nullOr (either validConfigTypes (listOf validConfigTypes))));
        default = [ ];
        description = "forward-zone: clauses configuration";
      };
      python = mkOption {
        type = with types; attrsOf (nullOr (either validConfigTypes (listOf validConfigTypes)));
        default = { };
        description = "python: clause configuration";
      };
    };
  };

  yesOrNo = v: if v then "yes" else "no";

  toOption = n: v: "${toString n}: ${v}";

  toConf = n: v:
    if builtins.isFloat v then (toOption n (toString v))
    else if isInt v       then (toOption n (toString v))
    else if isBool v      then (toOption n (yesOrNo v))
    else if isString v    then (toOption n v)
    else if isList v      then (concatMapStringsSep "\n  " (toConf n) v)
    else abort "unbound.toConf: unexpected type (n = ${n})";

  clauseConf = clause: conf: if conf == { } then "" else
    (concatStringsSep "\n  " (
      ["${clause}:"] ++ (
        mapAttrsToList toConf (
          filterAttrs (_: v: v != null) conf
        )
      )));

  confFile = pkgs.writeText "unbound.conf" (concatStringsSep "\n" (flatten [
    (clauseConf "server" cfg.settings.server)
    (clauseConf "remote-control" cfg.settings.remote-control)
    (map (clauseConf "stub-zone") cfg.settings.stub-zone)
    (map (clauseConf "forward-zone") cfg.settings.forward-zone)
    (clauseConf "python" cfg.settings.python)
  ]));

  rootTrustAnchorFile = "${cfg.stateDir}/root.key";

  unboundWrapped = pkgs.stdenv.mkDerivation {
    name = "unbound-wrapped";

    buildInputs = with pkgs; [ makeWrapper unbound ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p "$out/bin"
      makeWrapper ${pkgs.unbound}/bin/unbound-control $out/bin/unbound-control \
        --add-flags "-c ${cfg.stateDir}/unbound.conf"
      makeWrapper ${pkgs.unbound}/bin/unbound-checkconf $out/bin/unbound-checkconf \
        --add-flags "${cfg.stateDir}/unbound.conf"
    '';
  };

in

{

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
        type = with types; submodule settingsSubmodule;
        example = literalExample ''
          {
            server = {

            };
          };
        '';
        description = "Declarative Unbound configuration";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package (hiPrio unboundWrapped) ];

    services.unbound.settings = {
      server = {
        directory = cfg.stateDir;
        username = cfg.user;
        chroot = cfg.stateDir;
        pidfile = ''""'';
        interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        access-control = mkDefault [ "127.0.0.0/24 allow" ];
        auto-trust-anchor-file = if cfg.enableRootTrustAnchor then rootTrustAnchorFile else null;
      };
      remote-control = {
        control-enable = mkDefault false;
        control-interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        control-port = mkDefault 8953;
        server-key-file = mkDefault "${cfg.stateDir}/unbound_server.key";
        server-cert-file = mkDefault"${cfg.stateDir}/unbound_server.pem";
        control-key-file = mkDefault "${cfg.stateDir}/unbound_control.key";
        control-cert-file = mkDefault "${cfg.stateDir}/unbound_control.pem";
      };
    };

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
        cp ${confFile} ${cfg.stateDir}/unbound.conf
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
        ExecStart = "${cfg.package}/bin/unbound -d -c ${cfg.stateDir}/unbound.conf";
        ExecStopPost = "${pkgs.utillinux}/bin/umount ${cfg.stateDir}/dev/random";

        ProtectSystem = true;
        ProtectHome = true;
        PrivateDevices = true;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };

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
