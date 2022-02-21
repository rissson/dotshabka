{ soxincfg, config, pkgs, lib, ... }:

{
  networking = {
    hostName = "sas";
    domain = "rsn.lama.tel";
    hostId = "8425e349";

    nameservers = [ "1.1.1.1" ];

    useDHCP = true;

    /*dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';*/

    wireless = {
      enable = true;
      interfaces = [ "wlp0s20f3" ];
    };

    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
