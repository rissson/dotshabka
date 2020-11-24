{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking
    ./nfs.nix
    ./nginx.nix
    ./vault.nix
  ];

  home-manager.users.risson = import ./home.nix { inherit soxincfg; };

  lama-corp = {
    virtualisation = {
      libvirtd = {
        enable = true;
        images = [ "nixos" ];
      };
    };
  };

  soxin = {
    users = {
      enable = true;
      users = {
        risson = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1000;
          isAdmin = true;
          home = "/home/risson";
        };
        diego = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1010;
          isAdmin = true;
          home = "/home/diego";
        };
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
