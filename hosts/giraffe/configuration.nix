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

  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  # No users needed as we have a console access to this host
  shabka.users.enable = mkForce false;

  ###
  # Backups
  ###

  services.zfs.autoSnapshot.enable = mkForce false;

  services.borgbackup.jobs."nas-system" = {
    preHook = concatStrings [
      (optionalString config.services.influxdb.enable ''
        ${pkgs.influxdb}/bin/influxd backup -portable /srv/influxdb/dump
      '')
    ];

    postHook = concatStrings [
      (optionalString config.services.influxdb.enable ''
        rm -rf /srv/influxdb/dump
      '')
    ];

    readWritePaths = [
      "/srv/influxdb"
    ];

    startAt = "*-*-* *:33:53 UTC";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
