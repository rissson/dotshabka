{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    ./wireguard.nix
  ];

  networking = {
    hostName = "hedgehog";
    domain = "lap.rsn.lama-corp.space";
    hostId = "daec192f";

    nameservers = [ /*"172.28.254.6"*/ "1.1.1.1" ];

    useDHCP = true;

    /*dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';*/

    wireless = {
      enable = true;
      interfaces = [ "wlp1s0" ];
    };

    firewall = {
      allowedTCPPorts = [ 5060 5061 ];
      allowedUDPPorts = [ 5060 5061 7078 7079 9078 ];
    };
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
