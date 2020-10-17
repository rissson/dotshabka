{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.backups;
in {
  options = {
    lama-corp.common.backups = {
      enable = mkEnableOption "Enable backups to nas.srv.bar.lama-corp.space";

      startAt = mkOption {
        type = with types; either str (listOf str);
        default = "daily";
      };
    };
  };

  config = mkIf cfg.enable {
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

          inherit (cfg) startAt;

          extraCreateArgs = "--stats --progress --checkpoint-interval 600";
          extraPruneArgs = "--stats --save-space --list --progress";
        };
      };
    };
  };
}
