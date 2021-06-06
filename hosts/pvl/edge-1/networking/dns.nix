{ config, dns, pkgs, ... }:

let
  lamaTelZoneFile = pkgs.writeTextDir "lama.tel.zone" (dns.lib.toString "lama.tel" lamaTelZone);
  lamaTelZone = with dns.lib.combinators; {
    SOA = {
      nameServer = "ns1.lama.tel.";
      adminEmail = "hostmaster@lama-corp.space";
      serial = 2021060605;
      refresh = 60 * 60 * 4; # 4h in seconds
      retry = 60 * 60; # 1h, in seconds
      expire = 60 * 60 * 24 * 7; # 14d, in seconds
      minimum = 5 * 60; # 5h, in minutes
    };

    NS = [ "ns1" "ns2" ];

    CAA = letsEncrypt "caa@lama-corp.space";

    subdomains = {
      ns1 = host "108.61.208.236" "2a05:f480:1c00:9ee::53";
      ns2 = host "185.101.96.121" null;
      lg = {
        CNAME = [ "kvm-2.srv.fsn.lama-corp.space." ];
      };

      pvl.subdomains = {
        edge-1 = (host "172.28.254.4" null) // {
          subdomains = {
            pub = host "108.61.208.236" "2a05:f480:1c00:9ee:5400:3ff:fe21:2eeb";
          };
        };
      };

      avh.subdomains = {
        edge-2 = (host "172.28.254.5" null) // {
          subdomains = {
            pub = host "185.101.96.121" "2a00:1098:2e:2::1";
          };
        };
      };
    };
  };

  _2a06e88177ZoneFile = pkgs.writeTextDir "7.7.1.8.8.e.6.0.a.2.ip6.arpa.zone" (dns.lib.toString "7.7.1.8.8.e.6.0.a.2.ip6.arpa" _2a06e88177Zone);
  _2a06e88177Zone = with dns.lib.combinators; {
    SOA = {
      nameServer = "ns1.lama.tel.";
      adminEmail = "hostmaster@lama-corp.space";
      serial = 2021060602;
      refresh = 60 * 60 * 4; # 4h in seconds
      retry = 60 * 60; # 1h, in seconds
      expire = 60 * 60 * 24 * 7; # 14d, in seconds
      minimum = 5 * 60; # 5h, in minutes
    };

    NS = [ "ns1.lama.tel." "ns2.lama.tel." ];
  };

  _2001067217fcZoneFile = pkgs.writeTextDir "c.f.7.1.c.7.6.0.1.0.0.2.ip6.arpa.zone" (dns.lib.toString "c.f.7.1.c.7.6.0.1.0.0.2.ip6.arpa" _2001067217fcZone);
  _2001067217fcZone = with dns.lib.combinators; {
    SOA = {
      nameServer = "ns1.lama.tel.";
      adminEmail = "hostmaster@lama-corp.space";
      serial = 2021060602;
      refresh = 60 * 60 * 4; # 4h in seconds
      retry = 60 * 60; # 1h, in seconds
      expire = 60 * 60 * 24 * 7; # 14d, in seconds
      minimum = 5 * 60; # 5h, in minutes
    };

    NS = [ "ns1.lama.tel." "ns2.lama.tel." ];
  };

  knotZonesEnv = pkgs.buildEnv {
    name = "knot-zones";
    paths = [ lamaTelZoneFile _2a06e88177ZoneFile _2001067217fcZoneFile ];
  };
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  sops.secrets.tsig_ns2_slave = {
    sopsFile = ./dns.yml;
    owner = "knot";
  };
  users.users.knot.extraGroups = [ "keys" ];

  services.knot = {
    enable = true;
    keyFiles = [
      config.sops.secrets.tsig_ns2_slave.path
    ];
    extraConfig = ''
      server:
        listen: 108.61.208.236@53
        listen: 2a05:f480:1c00:9ee::53@53
        listen: 172.28.253.4@53
        listen: 2001:67c:17fc:fffe::4@53

      log:
        - target: syslog
          any: info

      mod-rrl:
        - id: default
          rate-limit: 200 # Allow 200 resp/s for each flow
          slip: 2 # Every other response slips

      acl:
        - id: ns2_slave_acl
          address: 172.28.253.5
          key: ns2_slave
          action: transfer

      remote:
        - id: ns2_slave
          address: 172.28.253.5@53
          key: ns2_slave

      database:
        # move databases below the state directory, because they need to be
        # writable
        journal-db: /var/lib/knot/journal
        kasp-db: /var/lib/knot/kasp
        timer-db: /var/lib/knot/timer

      template:
        - id: master
          # Input-only zone files
          storage: ${knotZonesEnv}
          # https://www.knot-dns.cz/docs/2.8/html/operation.html#example-3
          # prevents modification of the zonefiles, since the zonefiles are
          # immutable
          zonefile-sync: -1
          zonefile-load: difference
          journal-content: changes

          notify: [ns2_slave]
          acl: [ns2_slave_acl]

          semantic-checks: on

      zone:
        - domain: lama.tel
          file: lama.tel.zone
          template: master

        - domain: c.f.7.1.c.7.6.0.1.0.0.2.ip6.arpa
          file: c.f.7.1.c.7.6.0.1.0.0.2.ip6.arpa.zone
          template: master

        - domain: 7.7.1.8.8.e.6.0.a.2.ip6.arpa
          file: 7.7.1.8.8.e.6.0.a.2.ip6.arpa.zone
          template: master
    '';
  };
}
