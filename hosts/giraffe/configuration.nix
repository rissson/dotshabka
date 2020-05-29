{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/profiles/nixos/primary>
    <dotshabka/profiles/nixos/vm>
    <dotshabka/profiles/nixos/luks>

    ./hardware-configuration.nix
    ./networking
    ./monitoring
    ./backups.nix

  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  shabka.users.enable = mkForce false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
