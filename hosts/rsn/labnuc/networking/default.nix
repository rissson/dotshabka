{ soxincfg, config, pkgs, lib, ... }:

{
  networking = {
    hostName = "labnuc";
    domain = "lap.rsn.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "1.1.1.1" ];

    useDHCP = true;

    wireless = {
      enable = true;
      interfaces = [ "wlp58s0" ];
    };
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
