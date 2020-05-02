{ config, lib, pkgs, ... }:

with lib;

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};
in {
  nixpkgs.overlays = [
    (self: super: {
      netdata = nixpkgs.netdata;
    })
  ];

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

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/health_alarm_notify.conf".text = ''
      sendmail="${pkgs.system-sendmail}/bin/sendmail"
      curl="${pkgs.curl}/bin/curl"
      SEND_EMAIL="YES"
      DEFAULT_RECIPIENT_EMAIL="root@lama-corp.ovh"
      role_recipients_email[sysadmin]=root@lama-corp.ovh
    '';
  };
}
