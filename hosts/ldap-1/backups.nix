{ config, pkgs, lib, ... }:

with lib;

{
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
            (optionalString config.services.openldap.enable ''
                ${pkgs.openldap}/bin/slapcat -F ${config.services.openldap.configDir} -l /srv/ldap/ldap_backup.ldif
            '')
          ];

          readWritePaths = [
            "/srv/ldap"
          ];

          startAt = "*-*-* *:08:04 UTC";
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
