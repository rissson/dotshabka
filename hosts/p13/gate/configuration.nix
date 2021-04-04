{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "gate";
    domain = "srv.p13.lama-corp.space";
    hostId = "8425e349";

    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
