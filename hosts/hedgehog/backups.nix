{ ... }:

{
  services.borgbackup = {
    jobs = {
      "system" = {
        repo = "ssh://borg@nas.srv.bar.lama-corp.space/./backups/system";
        compression = "zlib,1";

        encryption.mode = "none";
        environment.BORG_RSH = "ssh -i /srv/secrets/borg/system.ssh.key";

        paths = [ "/root" "/srv" "/var/log" ];

        prune = {
          keep = {
            within = "1d";
            daily = 7;
            weekly = 4;
            monthly = 12;
          };
        };

        startAt = "daily";

        extraCreateArgs = "--stats --progress --checkpoint-interval 600";
        extraPruneArgs = "--stats --save-space --list --progress";
      };

      "nas-homes" = {
        repo = "ssh://borg@nas.srv.bar.lama-corp.space/./backups/homes";
        compression = "zlib,1";

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat /srv/secrets/root/backups/borg-nas-backups.passwd";
        };
        environment.BORG_RSH =
          "ssh -i /srv/secrets/root/backups/borg-nas-backups.ssh.key";

        paths = [ "/home" "/root" "/srv" ];

        startAt = "*-*-* 02:02:54 UTC";
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
