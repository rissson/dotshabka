{ config, lib, ... }:

with lib;

{
  services.rspamd = mkIf config.services.postfix.enable {
    enable = true;
    locals = {
      "milter_headers.conf" = {
        text = ''
          extended_spam_headers = yes;
        '';
      };
      "antivirus.conf" = {
        text = ''
          clamav {
            action = "reject";
            symbol = "CLAM_VIRUS";
            type = "clamav";
            log_clean = true;
            servers = "/run/clamav/clamd.ctl";
            scan_mime_parts = false; # scan mail as a whole unit, not parts. seems to be needed to work at all
          }
        '';
      };
    };

    overrides = {
      "milter_headers.conf" = {
        text = ''
          extended_spam_headers = true;
        '';
      };
    };

    workers.rspamd_proxy = {
      type = "rspamd_proxy";
      bindSockets = [{
        socket = "/run/rspamd/rspamd-milter.sock";
        mode = "0664";
      }];
      count = 1; # Do not spawn too many processes of this type
      extraConfig = ''
        milter = yes; # Enable milter mode
        timeout = 120s; # Needed for Milter usually

        upstream "local" {
          default = yes; # Self-scan upstreams are always default
          self_scan = yes; # Enable self-scan
        }
      '';
    };
    workers.controller = {
      type = "controller";
      count = 1;
      bindSockets = [{
        socket = "/run/rspamd/worker-controller.sock";
        mode = "0666";
      }];
      includes = [];
    };
  };

  systemd.services.rspamd = {
    requires = [ "clamav-daemon.service" ];
    after = [ "clamav-daemon.service" ];
  };

  systemd.services.postfix = {
    after = [ "rspamd.service" ];
    requires = [ "rspamd.service" ];
  };

  users.extraUsers.${config.services.postfix.user}.extraGroups = [
    config.services.rspamd.group
  ];
}
