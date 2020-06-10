{ config, pkgs, lib, ... }:

with lib;

let
  nixpkgs-flakes = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-flakes";
    url = "https://github.com/NixOS/nixpkgs/archive/b953766507552d50b9baa59dbc712f52c25609fd.tar.gz";
    sha256 = "16bp423mf6dlwsf4y3phf2p10lms0c7mygsdr31g0z2xp5a5n9i6";
  }) {};
in {
  imports = [
    <shabka/modules/nixos>
    <dotshabka/modules/nixos>
    <dotshabka/modules/nixos/workstation>

    ./hardware-configuration.nix
    ./networking
    ./backups.nix

    ./home.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.package = nixpkgs-flakes.nixFlakes;

  shabka.keyboard = {
    layouts = [ "bepo" "qwerty_intl" ];
    enableAtBoot = mkForce false;
  };

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.workstation = {
    teamviewer.enable = false;
    virtualbox.enable = mkForce false;
  };
  hardware.pulseaudio.zeroconf.discovery.enable = true;

  users.users.root = {
    hashedPassword =
      "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = config.shabka.users.users.risson.sshKeys;
  };

  shabka.users = with import <dotshabka/data/users> { }; {
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
