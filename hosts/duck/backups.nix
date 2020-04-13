{ ... }:

{
  services.borgbackup = {
    jobs = {
      "nas-system" = {
        repo = "ssh://borg@172.28.2.1/./backups/system";
        compression = "zlib,1";

        encryption.mode = "none";
        environment.BORG_RSH = "ssh -i /srv/secrets/root/backups/borg-nas-backups-system.ssh.key";

        paths = [
          "/boot"
          "/opt"
          "/srv"
          "/var/db"
          "/var/lib"
          "/var/log"
          "/var/spool"
        ];

        startAt = "*-*-* *:44:30 UTC";
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

      "nas-homes" = {
        repo = "ssh://borg@172.28.2.1/./backups/homes";
        compression = "zlib,1";

        encryption.mode = "none";
        environment.BORG_RSH = "ssh -i /srv/secrets/root/backups/borg-nas-backups-system.ssh.key";

        paths = [
          "/home"
          "/root"
        ];

        startAt = "*-*-* *:39:30 UTC";
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

      "hetzner-homes" = {
        repo = "ssh://u221979@u221979.your-storagebox.de:23/./backups/duck/homes";
        compression = "zlib,1";

        encryption = {
          mode = "repokey";
          passCommand = "cat /srv/secrets/root/backups/borg-u221979-backups-duck-homes.repo.passwd";
        };
        environment.BORG_RSH = "ssh -i /srv/secrets/root/backups/borg-u221979-backups-duck-homes.ssh.key";

        paths = [
          "/home"
          "/root"
        ];

        startAt = "*-*-* 03:07:15 UTC";
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
