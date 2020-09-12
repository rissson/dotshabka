{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.lama-corp.netdata;

  shabka = import <shabka> { };
  nixpkgs = import shabka.external.nixpkgs.release-unstable.path { };

  isPrimary = config.lama-corp.profiles.primary.enable;
in {
  options = {
    lama-corp.netdata.enable = mkEnableOption "Enable netdata";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (self: super: { netdata = nixpkgs.netdata; }) ];

    services.netdata = {
      enable = true;
      config = {
        backend = {
          enabled = "yes";
          type = "opentsdb";
          destination = "giraffe.srv.nbg.lama-corp.space:20042";
        };
      };
    };

    systemd.services.netdata.serviceConfig = {
      Restart = mkForce "always";
      RuntimeMaxSec = "1d";
    };

    lama-corp.sendmail.enable = config.services.netdata.enable;

    environment.etc = mkIf config.services.netdata.enable (mkMerge [
      {
        "netdata/health_alarm_notify.conf".text = ''
          sendmail="${pkgs.system-sendmail}/bin/sendmail"
          curl="${pkgs.curl}/bin/curl"
          SEND_EMAIL="YES"
          DEFAULT_RECIPIENT_EMAIL="${config.lama-corp.sendmail.recipientAddress}"
          role_recipients_email[sysadmin]=${config.lama-corp.sendmail.recipientAddress}
        '';

        "netdata/python.d.conf".text = concatStringsSep "\n" [
          "example: no"
          "httpcheck: no"
          (optionalString config.shabka.users.enable "logind: yes")
        ];

        "netdata/go.d.conf".text = concatStringsSep "\n" [
          "modules:"
          (optionalString config.lama-corp.unbound.enable "  unbound: yes")
          (optionalString isPrimary "  httpcheck: yes")
        ];
      }

      (optionalAttrs config.lama-corp.unbound.enable {
        "netdata/go.d/unbound.conf".text = builtins.readFile ./go.d/unbound.conf;
      })

      (optionalAttrs isPrimary {
        "netdata/go.d/httpcheck.conf".text =
          builtins.readFile ./go.d/httpcheck.conf;
        "netdata/go.d/portcheck.conf".text =
          builtins.readFile ./go.d/portcheck.conf;
        "netdata/go.d/x509check.conf".text =
          builtins.readFile ./go.d/x509check.conf;
      })
    ]);
  };
}
