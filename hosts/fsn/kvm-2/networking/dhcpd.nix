{ ... }:

{
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "br-k8s" ];
    extraConfig = ''
      authoritative;

      option routers 172.28.7.254;
      option broadcast-address 172.28.7.255;
      option subnet-mask 255.255.255.0;
      option domain-name-servers 172.28.7.254;
      option domain-name "k8s.fsn.lama-corp.space";
      subnet 172.28.7.0 netmask 255.255.255.0 {
        range 172.28.7.200 172.28.7.230;
      }
    '';

    machines = [
      {
        ethernetAddress = "52:54:00:00:00:0a";
        hostName = "master-11";
        ipAddress = "172.28.7.11";
      }
      {
        ethernetAddress = "52:54:00:00:00:0b";
        hostName = "master-12";
        ipAddress = "172.28.7.12";
      }
      {
        ethernetAddress = "52:54:00:00:00:0c";
        hostName = "master-13";
        ipAddress = "172.28.7.13";
      }
      {
        ethernetAddress = "52:54:00:00:00:6f";
        hostName = "worker-11";
        ipAddress = "172.28.7.111";
      }
      {
        ethernetAddress = "52:54:00:00:00:70";
        hostName = "worker-12";
        ipAddress = "172.28.7.112";
      }
      {
        ethernetAddress = "52:54:00:00:00:71";
        hostName = "worker-13";
        ipAddress = "172.28.7.113";
      }
    ];
  };
}
