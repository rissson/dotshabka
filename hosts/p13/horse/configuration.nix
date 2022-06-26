{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking.nix
  ];

  nix.gc.automatic = lib.mkForce false;

  services.xserver.videoDrivers = [ "nouveau" ];

  virtualisation.docker.storageDriver = "zfs";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}
