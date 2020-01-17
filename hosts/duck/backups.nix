{ config, lib, pkgs, ... }:

with lib;

{
  services.borgbackup = {
    jobs = {
      "homes" = {
        repo = "ssh://u221979@u221979.your-storagebox.de:23/./backups/duck";

        compression = "lzma";

        encryption.mode = "repokey";
        environment.BORG_RSH = "ssh -i /root/.ssh/id_ed25519_u221979";

        paths = [ # TODO: generate this from the list of users
          "/home/risson" "/home/lewdax" "/home/diego"
        ];

        startAt = "6h";

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
