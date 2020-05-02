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
    "netdata/go.d.conf".text = ''
      modules:
        httpcheck: yes
    '';
    "netdata/go.d/httpcheck.conf".text =
      builtins.readFile ./go.d/httpcheck.conf;
    "netdata/go.d/portcheck.conf".text =
      builtins.readFile ./go.d/portcheck.conf;
    "netdata/go.d/x509check.conf".text =
      builtins.readFile ./go.d/x509check.conf;

    "netdata/python.d.conf".text = ''
      example: no
      httpcheck: no
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
