{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> {};
  dotshabka = import <dotshabka> {};
in {
  imports =
    [
      <shabka/modules/nixos>
      <dotshabka/modules/nixos>
      <dotshabka/modules/nixos/server>

      ./hardware-configuration.nix
      ./networking
      ./users.nix
      ./backups.nix
      ./monitoring
      ./services
      ./home
    ]
    ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets") (singleton "${<dotshabka>}/secrets"));

  shabka.keyboard.layouts = [ "qwerty" ];
  shabka.keyboard.enableAtBoot = true;

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.neovim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
