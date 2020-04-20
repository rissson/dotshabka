{ pkgs, lib, ... }:

with lib;

let
  dotshabka = import <dotshabka> {};
in with dotshabka.data.iPs.space.lama-corp; {
  services.unbound = {
    enable = true;
    interfaces = [ "127.0.0.1" "::1" fsn.srv.duck.wg.v4.ip ];
    allowedAccess = [ "0.0.0.0/0" "::0/0" ];
    enableRootTrustAnchor = true;
    extraConfig = ''
        statistics-cumulative: yes
        extended-statistics: yes

        tls-cert-bundle: ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
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

        domain-insecure: "bar.lama-corp.space"
        local-zone: "44.168.192.in-addr.arpa." transparent
        local-data: "nas.srv.bar.lama-corp.space. IN A ${bar.srv.nas.wg.v4.ip}"
        local-data-ptr: "${bar.srv.nas.wg.v4.ip} nas.srv.bar.lama-corp.space"

        domain-insecure: "fly.lama-corp.space"
        local-zone: "fly.lama-corp.space." static
        local-data: "hedgehog.lap.fly.lama-corp.space. IN A ${fly.lap.hedgehog.wg.v4.ip}"
        local-data-ptr: "${fly.lap.hedgehog.wg.v4.ip} hedgehog.lap.fly.lama-corp.space"
        local-data: "trunck.lap.fly.lama-corp.space. IN A ${fly.lap.trunck.wg.v4.ip}"
        local-data-ptr: "${fly.lap.trunck.wg.v4.ip} trunck.lap.fly.lama-corp.space"

        domain-insecure: "fsn.lama-corp.space"
        local-zone: "fsn.lama-corp.space." static
        local-data: "duck.srv.fsn.lama-corp.space. IN A ${fsn.srv.duck.wg.v4.ip}"
        local-data-ptr: "${fsn.srv.duck.wg.v4.ip} duck.srv.fsn.lama-corp.space"
        local-data: "hub.virt.duck.srv.fsn.lama-corp.space. IN A ${fsn.srv.duck.virt.hub.wg.v4.ip}"
        local-data-ptr: "${fsn.srv.duck.virt.hub.wg.v4.ip} hub.virt.duck.srv.fsn.lama-corp.space"

      forward-zone:
        name: "bar.lama-corp.space."
        forward-addr: ${bar.srv.nas.wg.v4.ip}
      forward-zone:
        name: "44.168.192.in-addr.arpa."
        forward-addr: ${bar.srv.nas.wg.v4.ip}

      forward-zone:
        name: "."
        forward-tls-upstream: yes
        forward-addr: 45.90.28.0#61ba3a.dns1.nextdns.io
        forward-addr: 2a07:a8c0::#61ba3a.dns1.nextdns.io
        forward-addr: 45.90.30.0#61ba3a.dns2.nextdns.io
        forward-addr: 2a07:a8c1::#61ba3a.dns2.nextdns.io
        forward-addr: 1.1.1.1@853#cloudflare-dns.com
        forward-addr: 1.0.0.1@853#cloudflare-dns.com

      remote-control:
        control-enable: yes
        control-interface: "127.0.0.1"
        control-interface: "::1"
        control-port: 8953
        control-use-cert: no
    '';
  };
}
