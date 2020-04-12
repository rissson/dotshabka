{ ... }:

{
  services.borgbackup = {
    jobs = {
      "homes" = {
      repo = "ssh://u221979@u221979.your-storagebox.de:23/./backups/duck/homes";

      compression = "zlib,1";

      encryption = {
        mode = "repokey";
        passCommand = "cat /srv/secrets/root/borg-u221979-backups-duck-homes.bak.passwd";
      };

      environment.BORG_RSH = "ssh -i /root/.ssh/id_ed25519_u221979";

      paths = [
        "/home" "/root"
      ];

      startAt = "3:15";

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
