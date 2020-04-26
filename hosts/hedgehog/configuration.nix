{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/modules/nixos>
    <dotshabka/modules/nixos/workstation>

    ./hardware-configuration.nix
    ./networking.nix
    ./backups.nix

    ./home.nix
  ]
  ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets") (singleton "${<dotshabka>}/secrets"));

  shabka.keyboard = {
    layouts = [ "bepo" "qwerty_intl" ];
    enableAtBoot = false;
  };

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.workstation = {
    teamviewer.enable = true;
    virtualbox.enable = mkForce false;
  };

  users.users.root = {
    hashedPassword = "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = config.shabka.users.users.risson.sshKeys;
  };

  shabka.users = with import <dotshabka/data/users> {}; {
    enable = true;
    users = {
      risson = {
        inherit (risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
