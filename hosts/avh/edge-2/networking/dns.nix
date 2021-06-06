{ config, ... }:

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
        listen: 185.101.96.121@53
        listen: 2a00:1098:2e:2::1@53
        listen: 172.28.253.5@53
        listen: 2001:67c:17fc:fffe::5@53

      log:
        - target: syslog
          any: info

      mod-rrl:
        - id: default
          rate-limit: 200 # Allow 200 resp/s for each flow
          slip: 2 # Every other response slips

      acl:
        - id: ns1_notify_acl
          address: 172.28.253.4
          key: ns2_slave
          action: notify

      remote:
        - id: ns1_master
          address: 172.28.253.4@53
          key: ns2_slave

      database:
        journal-db: /var/lib/knot/journal
        kasp-db: /var/lib/knot/kasp
        timer-db: /var/lib/knot/timer

      template:
        - id: slave
          master: [ns1_master]
          storage: /var/lib/knot/zones/
          acl: [ns1_notify_acl]

      zone:
        - domain: lama.tel
          template: slave

        - domain: c.f.7.1.c.7.6.0.1.0.0.2.ip6.arpa
          template: slave

        - domain: 7.7.1.8.8.e.6.0.a.2.ip6.arpa
          template: slave
    '';
  };
}
