{ ... }:

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "br-vms" "br-k8s" ];
    extraConfig = ''
      authoritative;

      option routers 172.28.6.254;
      option broadcast-address 172.28.6.255;
      option subnet-mask 255.255.255.0;
      option domain-name-servers 172.28.6.254;
      option domain-name "vrt.fsn.lama-corp.space";
      subnet 172.28.6.0 netmask 255.255.255.0 {
        range 172.28.6.200 172.28.6.230;
      }
    '';

    machines = [
      {
        ethernetAddress = "52:54:00:00:06:c9";
        hostName = "pine";
        ipAddress = "172.28.6.201";
      }
    ];
  };
}
