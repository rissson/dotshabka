{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/modules/nixos>
    <dotshabka/modules/nixos/server>

    ./hardware-configuration.nix
    ./networking.nix
    ./backups.nix
    ./monitoring
    ./dns-dhcp.nix
    ./dyndns.nix

    ./home
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  shabka.users = with import <dotshabka/data/users> { }; {
    enable = true;
    users = {
      risson = {
        inherit (risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
      diego = {
        inherit (diego) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/diego";
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
