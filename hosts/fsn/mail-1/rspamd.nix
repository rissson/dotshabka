{ config, ... }:

{
  services.redis.enable = true;

  services.rspamd = {
    enable = true;
    extraConfig = ''
      local_networks = [ "172.28.0.0/16" ];
    '';

    locals = {
      "milter_headers.conf".text = ''
        extended_spam_headers = yes;
      '';
      "redis.conf".text = ''
        server = localhost:${toString config.services.redis.port};
      '';
      "classifier-bayes.conf".text = ''
        cache {
          backend = "redis";
        }
      '';
    };

    overrides = {
      "milter_headers.conf".text = ''
        extended_spam_headers = yes;
      '';
    };

    workers = {
      rspamd_proxy = {
        type = "rspamd_proxy";
        bindSockets = [{
          socket = "/run/rspamd/rspamd-milter.sock";
          mode = "0664";
        }];
        count = 1;
        extraConfig = ''
          milter = yes;
          timeout = 120s;

          upstream "local" {
            default = yes;
            self_scan = yes;
          }
        '';
      };

      controller = {
        type = "controller";
        count = 1;
        bindSockets = [{
          socket = "/run/rspamd/worker-controller.sock";
          mode = "0666";
        }];
        includes = [];
        extraConfig = ''
          static_dir = "''${WWWDIR}";
        '';
      };
    };
  };

  systemd.services.rspamd = {
    after = [ "redis.service" ];
    requires = [ "redis.service" ];
  };

  systemd.services.postfix = {
    after = [ "rspamd.service" ];
    requires = [ "rspamd.service" ];
  };

  users.users.${config.services.postfix.user}.extraGroups = [ config.services.rspamd.group ];
}
