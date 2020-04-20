{ config, lib, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        apache: no
        bind: no
        example: no
        freeradius: no
        lighttpd: no
        mysql: no
        nginx: yes
        openvpn: no
        phpfpm: no
        rabbitmq: no
        squidlog: no
        web_log: yes
        whoisquery: no
    '';
    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/web_log.conf".text = builtins.readFile ./go.d/web_log.conf;

    "netdata/python.d.conf".text = ''
      example: no
      logind: yes
      nginx: no
      web_log: no
    '';
  };
}
