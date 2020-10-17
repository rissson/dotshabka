{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };
  nixpkgs = import shabka.external.nixpkgs.release-unstable.path { };

  nixpkgs-flakes = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-flakes";
    url = "https://github.com/NixOS/nixpkgs/archive/cc739e1c67c31fec7483137f352d32e093e40b28.tar.gz";
    sha256 = "135n5lxyh24bvsfcx1zlhzd9ciqn83plqmzv8jkxg773w8bm5smk";
  }) {};
in {
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking
    ./backups.nix

    ./home.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "hedgehog";
    easyCerts = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  services.tlp.enable = mkForce false;

  lama-corp = {
    common.keyboard.enable = mkForce false;
    profiles.workstation = {
      enable = true;
      isLaptop = true;
      primaryUser = "risson";
    };
    luks.enable = true;
  };
  services.openssh.passwordAuthentication = mkForce false;

  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
  '';
  nix.package = nixpkgs-flakes.nixFlakes;
  nix.gc.automatic = mkForce false;

  shabka.keyboard = {
    layouts = mkForce [ "bepo" "qwerty_intl" ];
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

  nixpkgs.overlays = [
    (self: super: { fprintd = nixpkgs.fprintd; })
    (self: super: { libfprint = nixpkgs.libfprint; })
    (self: super: { libpam-wrapper = nixpkgs.libpam-wrapper; })
  ];
  services.fprintd.enable = true;

  users.users.root = {
    hashedPassword = mkForce
      "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = mkForce config.shabka.users.users.risson.sshKeys;
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
