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
        nginx: yes
        phpfpm: yes
        web_log: yes
    '';
    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/phpfpm.conf".text = builtins.readFile ./go.d/phpfpm.conf;
    "netdata/go.d/portcheck.conf".text = builtins.readFile ./go.d/portcheck.conf;
    "netdata/go.d/unbound.conf".text = builtins.readFile ./go.d/unbound.conf;
    "netdata/go.d/web_log.conf".text = builtins.readFile ./go.d/web_log.conf;

    "netdata/python.d.conf".text = ''
      example: no
      httpcheck: no
      logind: yes
      nginx: no
      phpfpm: no
      web_log: no
    '';

    "netdata/health_alarm_notify.conf".text = ''
      sendmail="${pkgs.system-sendmail}/bin/sendmail"
      curl="${pkgs.curl}/bin/curl"
      SEND_EMAIL="YES"
      DEFAULT_RECIPIENT_EMAIL="root@lama-corp.ovh"
      role_recipients_email[sysadmin]=root@lama-corp.ovh
    '';
  };
}
