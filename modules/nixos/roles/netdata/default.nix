{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.lama-corp.netdata;

  shabka = import <shabka> { };
  nixpkgs = import shabka.external.nixpkgs.release-unstable.path { };
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
      }

      (optionalAttrs config.lama-corp.profiles.primary.enable {

      })
    ]);
  };
}
