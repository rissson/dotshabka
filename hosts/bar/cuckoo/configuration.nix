{ soxincfg, pkgs, lib, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server

    ./hardware-configuration.nix
    ./chaudiered.nix
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/www/html"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  networking = {
    hostName = "cuckoo";
    domain = "srv.bar.lama-corp.space";
    hostId = "8425e349";

    useDHCP = false;

    interfaces = {
      enp4s11.useDHCP = true;
      wls33.useDHCP = true;
    };

    wireless = {
      enable = true;
      interfaces = [ "wls33" ];
    };
  };

  environment.etc."wpa_supplicant.conf".text = ''
    ctrl_interface=/run/wpa_supplicant
    ctrl_interface_group=wheel

    network={
      ssid="hello_world"
      psk="42L7MaSCHM1TT6364006757"
    }
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
