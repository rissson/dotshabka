{ ... }:

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "enp60s0" ];
    extraConfig = ''
      authoritative;

      option routers 192.168.3.254;
      option broadcast-address 192.168.3.255;
      option subnet-mask 255.255.255.0;
      option domain-name-servers 192.168.3.253;
      option domain-name "p13.lama-corp.space";
      subnet 192.168.3.0 netmask 255.255.255.0 {
        range 192.168.3.100 192.168.3.199;
      }
    '';
  };
}
