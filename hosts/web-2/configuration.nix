{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/profiles/nixos/vm>

    ./hardware-configuration.nix
    ./networking.nix

    ./mattermost
    ./web
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  ###
  # Backups
  ###

  services.borgbackup.jobs."nas-system".startAt = "*-*-* *:12:13 UTC";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
