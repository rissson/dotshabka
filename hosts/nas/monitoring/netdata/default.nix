{ config, lib, pkgs, ... }:

with lib;

{
  services.netdata.config = {
    backend = {
      enabled = "yes";
      type = "opentsdb";
      destination = "giraffe.srv.nbg.lama-corp.space:20042";
    };
  };

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/python.d.conf".text = ''
      example: no
      logind: yes
    '';

    "netdata/health_alarm_notify.conf".text = ''
      sendmail="${pkgs.system-sendmail}/bin/sendmail"
      curl="${pkgs.curl}/bin/curl"
      SEND_EMAIL="YES"
      DEFAULT_RECIPIENT_EMAIL="root@lama-corp.ovh"
    '';
  };
}
