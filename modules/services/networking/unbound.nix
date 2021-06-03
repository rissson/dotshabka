{ mode, config, pkgs, lib, modulesPath, ... }:

with lib;

let
  cfg = config.lama-corp.services.unbound;

  zonesData = {
    "bar.lama-corp.space" = "172.28.254.2";
    "2.28.172.in-addr.arpa" = "172.28.254.2";

    "p13.lama-corp.space" = "172.28.254.3";
    "3.28.172.in-addr.arpa" = "172.28.254.3";

    "par.lama-corp.space" = "172.28.254.4";
    "4.28.172.in-addr.arpa" = "172.28.254.4";

    "vha.lama-corp.space" = "172.28.254.5";
    "5.28.172.in-addr.arpa" = "172.28.254.5";

    "fsn.lama-corp.space" = "172.28.254.6";
    "6.28.172.in-addr.arpa" = "172.28.254.6";
    "7.28.172.in-addr.arpa" = "172.28.254.6";
    "8.28.172.in-addr.arpa" = "172.28.254.6";

    "rsn.lama-corp.space" = "172.28.254.101";
    "101.28.172.in-addr.arpa" = "172.28.254.101";
  };

  primariesData = {
    "nas-1.srv.bar" = "172.28.254.2";
    "rogue.srv.p13" = "172.28.254.3";
    "edge-1.srv.par" = "172.28.254.4";
    "edge-2.srv.vha" = "172.28.254.5";
    "kvm-2.srv.fsn" = "172.28.254.6";
    "hedgehog.lap.rsn" = "172.28.254.101";
  };
in
{
  options = {
    lama-corp.services.unbound = {
      enable = mkEnableOption "unbound recursive DNS server.";
      extraData = mkOption {
        default = {};
        type = with types; attrsOf str;
        description = "Extra data to serve.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {

      services.unbound = {
        enable = true;

        resolveLocalQueries = true;
        enableRootTrustAnchor = true;

        settings = {
          server = rec {
            interface = mkForce [ "0.0.0.0" ];
            access-control = [ "0.0.0.0/0 allow" "::0/0 allow" ];
            statistics-cumulative = true;
            extended-statistics = true;

            # Do not query the following addresses. No DNS queries are sent there.
            # List one address per entry. List classless netblocks with /size,
            # do-not-query-address = "127.0.0.1/8";
            # do-not-query-address = "::1";
            # the following makes the above default do-not-query-address entries
            # present.
            do-not-query-localhost = true;

            private-address = [
              ''"10.0.0.0/8"''
              ''"172.16.0.0/12"''
              ''"192.168.0.0/16"''
              ''"169.254.0.0/16"''
              ''"fd00::/8"''
              ''"fe80::/10"''
              ''"::ffff:0:0/96"''
            ];

            unblock-lan-zones = true;
            insecure-lan-zones = true;

            private-domain = mapAttrsToList (n: _: ''"${n}"'') zonesData;
            domain-insecure = private-domain;

            local-zone = mapAttrsToList (n: _: ''"${n}." transparent'') zonesData;

            local-data = mapAttrsToList (n: v: ''"${n}.lama-corp.space. IN A ${v}"'') (recursiveUpdate primariesData cfg.extraData);
            local-data-ptr = mapAttrsToList (n: v: ''"${v} ${n}.lama-corp.space"'') (recursiveUpdate primariesData cfg.extraData);
          };

          forward-zone = (mapAttrsToList (n: v: {
            name = "${n}.";
            forward-addr = v;
          }) zonesData) ++ (singleton {
            name = ".";
            forward-tls-upstream = true;
            forward-addr = [
              "45.90.28.0#61ba3a.dns1.nextdns.io"
              "2a07:a8c0::#61ba3a.dns1.nextdns.io"
              "45.90.30.0#61ba3a.dns2.nextdns.io"
              "2a07:a8c1::#61ba3a.dns2.nextdns.io"
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
          });

          remote-control = {
            control-enable = true;
            control-interface = [ "127.0.0.1" "::1" ];
            control-port = 8953;
            control-use-cert = false;
          };
        };
      };
    })
  ]);
}
