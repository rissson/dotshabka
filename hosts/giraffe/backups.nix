{ config, pkgs, lib, ... }:

with lib;

{
  services.zfs.autoSnapshot = {
    frequent = 4;
    hourly = mkForce 12;
    daily = mkForce 5;
    weekly = mkForce 1;
    monthly = mkForce 0;
  };

  services.borgbackup = {
    jobs = {
      "nas-system" = {
        repo = "ssh://borg@nas.srv.bar.lama-corp.space/./backups/system";
        compression = "zlib,1";

        encryption.mode = "none";
        environment.BORG_RSH =
          "ssh -i /srv/secrets/borg/nas-system.ssh.key";

          paths = [
            "/root"
            "/srv"
            "/var/log"
          ];

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
          prune = {
            keep = {
              within = "1d";
              daily = 7;
              weekly = 4;
              monthly = 12;
            };
          };

          extraCreateArgs = "--stats --progress --checkpoint-interval 600";
          extraPruneArgs = "--stats --save-space --list --progress";
        };
      };
    };
  }
