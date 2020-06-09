{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>

    <dotshabka/profiles/nixos/vm>

    <dotshabka/roles/nixos/postgres>

    ./hardware-configuration.nix
    ./networking.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  services.postgresql = {
    ensureDatabases = [ "catcdc" "codimd" "pastebin" "scoreboard_seedbox_cri" ];
    ensureUsers = [
      {
        name = "catcdc";
        ensurePermissions = { "DATABASE catcdc" = "ALL PRIVILEGES"; };
      }
      {
        name = "codimd";
        ensurePermissions = { "DATABASE codimd" = "ALL PRIVILEGES"; };
      }
      {
        name = "pastebin";
        ensurePermissions = { "DATABASE pastebin" = "ALL PRIVILEGES"; };
      }
      {
        name = "scoreboard_seedbox_cri";
        ensurePermissions = {
          "DATABASE scoreboard_seedbox_cri" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  ###
  # Backups
  ###

  services.borgbackup.jobs."system".startAt = "*-*-* *:00:06 UTC";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
