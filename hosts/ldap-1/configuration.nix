{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/profiles/nixos/vm>

    ./hardware-configuration.nix
    ./networking.nix

    ./ldap
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  ###
  # Backups
  ###

  services.borgbackup.jobs."nas-system" = {
    preHook = concatStrings [
      (optionalString config.services.openldap.enable ''
                ${pkgs.openldap}/bin/slapcat -F ${config.services.openldap.configDir} -l /srv/ldap/ldap_backup.ldif
      '')
    ];

    readWritePaths = [
      "/srv/ldap"
    ];

    startAt = "*-*-* *:08:04 UTC";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
