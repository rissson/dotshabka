{ ... }:

let
  dotshabka = import <dotshabka> {};
in {
  services.unbound = {
    enable = true;
    allowedAccess = [ "172.28.0.0/16" ];
    interfaces = [ "127.0.0.1" "::1" "172.28.1.1" ];
    extraConfig = ''
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
