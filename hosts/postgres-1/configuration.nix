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
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
