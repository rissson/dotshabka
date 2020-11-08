{ ... }:

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "bond0" ];
    extraConfig = ''
      authoritative;

      option routers 192.168.44.254;
      option broadcast-address 192.168.44.255;
      option subnet-mask 255.255.255.0;
      option domain-name-servers 192.168.44.253, 1.1.1.1;
      option domain-name "bar.lama-corp.space";
      subnet 192.168.44.0 netmask 255.255.255.0 {
        range 192.168.44.100 192.168.44.199;
      }
    '';

    machines = [
      {
        ethernetAddress = "00:09:82:17:1c:c0";
        hostName = "loewe.mmd";
        ipAddress = "192.168.44.221";
      }
      {
        ethernetAddress = "08:df:1f:08:49:34";
        hostName = "bose.mmd";
        ipAddress = "192.168.44.222";
      }
      {
        ethernetAddress = "48:d6:d5:27:2b:b4";
        hostName = "chromecast.mmd";
        ipAddress = "192.168.44.223";
      }
      {
        ethernetAddress = "88:51:fb:1b:21:f4";
        hostName = "hp.prt";
        ipAddress = "192.168.44.231";
      }
      {
        ethernetAddress = "44:fe:3b:1b:ed:3e";
        hostName = "floor0.wfi";
        ipAddress = "192.168.44.241";
      }
      {
        ethernetAddress = "00:e0:4c:90:a8:52";
        hostName = "floor-1.wfi";
        ipAddress = "192.168.44.242";
      }
      {
        ethernetAddress = "12:e0:00:d1:5d:c7";
        hostName = "cuckoo.srv";
        ipAddress = "192.168.44.245";
      }
      {
        ethernetAddress = "8e:3d:9b:ab:c9:c5";
        hostName = "nas.srv";
        ipAddress = "192.168.44.253";
      }
      {
        ethernetAddress = "78:81:02:13:49:4e";
        hostName = "livebox.srv";
        ipAddress = "192.168.44.254";
      }
    ];
  };
}
