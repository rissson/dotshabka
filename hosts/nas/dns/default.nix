{ pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { };

let

  data = with bar; {
    # bar
    "cuckoo.mmd.bar" = mmd.cuckoo.internal;
    "loewe.mmd.bar" = mmd.loewe.internal;
    "bose.mmd.bar" = mmd.bose.internal;
    "chromecast.mmd.bar" = mmd.chromecast.internal;
    "hp.prt.bar" = prt.hp.internal;
    "floor0.wfi.bar" = wfi.floor0.internal;
    "floor-1.wfi.bar" = wfi.floor-1.internal;
    # This is conflicting with the wg ip.
    # We will be able to remove it once we extract the primaries configuration
    #"nas.srv.bar" = srv.nas.internal;
    "livebox.srv.bar" = srv.livebox.internal;

    # Primaries
    "nas.srv.bar" = bar.srv.nas.wg;
    "trunck.lap.drn" = drn.lap.trunck.wg;
    "kvm-1.srv.fsn" = fsn.srv.kvm-1.wg;
    "giraffe.srv.nbg" = nbg.srv.giraffe.wg;
    "hedgehog.lap.rsn" = rsn.lap.hedgehog.wg;
  };

  mkLocalData = data: mapAttrsToList (
    n: v: ''"${n}.lama-corp.space. IN A ${v.v4.ip}"''
  ) data;

  mkLocalDataPtr = data: mapAttrsToList (
    n: v: ''"${v.v4.ip} ${n}.lama-corp.space"''
  ) data;

  local-data = mkLocalData data;
  local-data-ptr = mkLocalDataPtr data;

in  {
  disabledModules = [
    "services/networking/unbound.nix"
  ];

  imports = [
    ./unbound.nix
  ];

  services.unbound = {
    enable = true;

    resolveLocalQueries = true;
    enableRootTrustAnchor = true;

    settings = {
      server = {
        interface = with bar.srv.nas; [
          "127.0.0.1"
          "::1"
          wg.v4.ip
          wg.v6.ip
          internal.v4.ip
        ];
        access-control = [
          "0.0.0.0/0 allow"
          "::0/0 allow"
        ];
        statistics-cumulative = true;
        extended-statistics = true;

        tls-cert-bundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        # Do not query the following addresses. No DNS queries are sent there.
        # List one address per entry. List classless netblocks with /size,
        # do-not-query-address = "127.0.0.1/8";
        # do-not-query-address = "::1";
        # the following makes the above default do-not-query-address entries present.
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

        private-domain = [
          ''"bar.lama-corp.space"''
          ''"drn.lama-corp.space"''
          ''"fsn.lama-corp.space"''
          ''"nbg.lama-corp.space"''
          ''"rsn.lama-corp.space"''
        ];

        domain-insecure = [
          ''"bar.lama-corp.space"''
          ''"drn.lama-corp.space"''
          ''"fsn.lama-corp.space"''
          ''"nbg.lama-corp.space"''
          ''"rsn.lama-corp.space"''
        ];

        local-zone = [
          ''"bar.lama-corp.space." transparent''
          ''"2.28.172.in-addr.arpa." transparent''
          ''"44.168.192.in-addr.arpa." transparent''
          ''"drn.lama-corp.space." transparent''
          ''"102.28.172.in-addr.arpa." transparent''
          ''"fsn.lama-corp.space." transparent''
          ''"1.28.172.in-addr.arpa." transparent''
          ''"nbg.lama-corp.space." transparent''
          ''"3.28.172.in-addr.arpa." transparent''
          ''"rsn.lama-corp.space." transparent''
          ''"101.28.172.in-addr.arpa." transparent''
        ];

        inherit local-data local-data-ptr;
      };

      forward-zone = [
        # bar
        {
          name = "bar.lama-corp.space.";
          forward-addr = bar.srv.nas.wg.v4.ip;
        }
        {
          name = "2.28.172.in-addr.arpa.";
          forward-addr = bar.srv.nas.wg.v4.ip;
        }
        {
          name = "44.168.192.in-addr.arpa.";
          forward-addr = bar.srv.nas.wg.v4.ip;
        }

        # drn
        {
          name = "drn.lama-corp.space.";
          forward-addr = drn.lap.trunck.wg.v4.ip;
        }
        {
          name = "102.28.172.in-addr.arpa.";
          forward-addr = drn.lap.trunck.wg.v4.ip;
        }

        # fsn
        {
          name = "fsn.lama-corp.space.";
          forward-addr = fsn.srv.kvm-1.wg.v4.ip;
        }
        {
          name = "1.28.172.in-addr.arpa.";
          forward-addr = fsn.srv.kvm-1.wg.v4.ip;
        }

        # nbg
        {
          name = "nbg.lama-corp.space.";
          forward-addr = nbg.srv.giraffe.wg.v4.ip;
        }
        {
          name = "3.28.172.in-addr.arpa.";
          forward-addr = nbg.srv.giraffe.wg.v4.ip;
        }

        # rsn
        {
          name = "rsn.lama-corp.space.";
          forward-addr = rsn.lap.hedgehog.wg.v4.ip;
        }
        {
          name = "101.28.172.in-addr.arpa.";
          forward-addr = rsn.lap.hedgehog.wg.v4.ip;
        }

        # other
        {
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
        }
      ];

      remote-control = {
        control-enable = true;
        control-interface = [
          "127.0.0.1"
          "::1"
        ];
        control-port = 8953;
        control-use-cert = false;
      };
    };
  };
}
