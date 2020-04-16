{ lib, ... }:

with lib;

let
  dotshabka = import <dotshabka> {};
in with dotshabka.data.iPs; {
  services.unbound = {
    enable = true;
    interfaces = [ "0.0.0.0" "::0" ];
    allowedAccess = [ "0.0.0.0/0" "::0/0" ];
    enableRootTrustAnchor = true;
    extraConfig = ''
        # Do not query the following addresses. No DNS queries are sent there.
        # List one address per entry. List classless netblocks with /size,
        # do-not-query-address: 127.0.0.1/8
        # do-not-query-address: ::1
        # the following makes the above default do-not-query-address entries present.
        do-not-query-localhost: yes

        private-address: 10.0.0.0/8
        private-address: 172.16.0.0/12
        private-address: 192.168.0.0/16
        private-address: 169.254.0.0/16
        private-address: fd00::/8
        private-address: fe80::/10
        private-address: ::ffff:0:0/96

        private-domain: "bar.lama-corp.space"
        private-domain: "fly.lama-corp.space"
        private-domain: "fsn.lama-corp.space"

        unblock-lan-zones: yes
        insecure-lan-zones: yes

        insecure-domain: "bar.lama-corp.space"
        insecure-domain: "fly.lama-corp.space"
        insecure-domain: "fsn.lama-corp.space"

        local-zone: "44.168.192.in-addr.arpa." transparent

      forward-zone:
        name: "bar.lama-corp.space."
        forward-addr: 172.28.2.1
      forward-zone:
        name: "44.168.192.in-addr.arpa."
        forawrd-addr: 172.28.2.1

      forward-zone:
        name: "."
        forward-tls-upstream: yes
        forward-addr: 45.90.28.0#61ba3a.dns1.nextdns.io
        forward-addr: 2a07:a8c0::#61ba3a.dns1.nextdns.io
        forward-addr: 45.90.30.0#61ba3a.dns2.nextdns.io
        forward-addr: 2a07:a8c1::#61ba3a.dns2.nextdns.io
    '';
  };
}
