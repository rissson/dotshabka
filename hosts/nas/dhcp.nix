{ ... }:

with import <dotshabka/data> { };
with space.lama-corp.bar;

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ srv.nas.internal.interface ];
    machines = [
      {
        hostName = "loewe.mmd";
        ipAddress = mmd.loewe.internal.v4.ip;
        ethernetAddress = mmd.loewe.internal.mac;
      }
      {
        hostName = "bose.mmd";
        ipAddress = mmd.bose.internal.v4.ip;
        ethernetAddress = mmd.bose.internal.mac;
      }
      {
        hostName = "chromecast.mmd";
        ipAddress = mmd.chromecast.internal.v4.ip;
        ethernetAddress = mmd.chromecast.internal.mac;
      }

      {
        hostName = "hp.prt";
        ipAddress = prt.hp.internal.v4.ip;
        ethernetAddress = prt.hp.internal.mac;
      }

      {
        hostName = "floor0.wfi";
        ipAddress = wfi.floor0.internal.v4.ip;
        ethernetAddress = wfi.floor0.internal.mac;
      }
      {
        hostName = "floor-1.wfi";
        ipAddress = wfi.floor-1.internal.v4.ip;
        ethernetAddress = wfi.floor-1.internal.mac;
      }

      {
        hostName = "cuckoo.srv";
        ipAddress = srv.cuckoo.internal.v4.ip;
        ethernetAddress = srv.cuckoo.internal.mac;
      }
      {
        hostName = "nas.srv";
        ipAddress = srv.nas.internal.v4.ip;
        ethernetAddress = srv.nas.internal.mac;
      }
      {
        hostName = "livebox.srv";
        ipAddress = srv.livebox.internal.v4.ip;
        ethernetAddress = srv.livebox.internal.mac;
      }
    ];
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
