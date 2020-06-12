{ lib, ... }:

with lib;

with import <dotshabka/data> { };
with space.lama-corp.bar;

let
  data = {
    "loewe.mmd" = mmd.loewe;
    "bose.mmd" = mmd.bose;
    "chromecast.mmd" = mmd.chromecast;
    "hp.prt" = prt.hp;
    "floor0.wfi" = wfi.floor0;
    "floor-1.wfi" = wfi.floor-1;
    "cuckoo.srv" = srv.cuckoo;
    "nas.srv" = srv.nas;
    "livebox.srv" = srv.livebox;
  };
in {
  services.dhcpd4 = {
    enable = true;
    interfaces = [ srv.nas.internal.interface ];

    machines = mapAttrsToList (n: v: { hostName = n; ipAddress = v.internal.v4.ip; ethernetAddress = v.internal.mac; }) data;

    extraConfig = ''
      authoritative;

      option subnet-mask 255.255.255.0;
      option broadcast-address 192.168.44.255;
      option routers ${srv.livebox.internal.v4.ip};
      option domain-name-servers ${srv.nas.internal.v4.ip}, ${
        builtins.elemAt externalNameservers 1
      };
      option domain-name "bar.lama-corp.space";
      subnet 192.168.44.0 netmask 255.255.255.0 {
        range ${dhcp.start} ${dhcp.end};
      }
    '';
  };
}
