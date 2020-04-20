{ config, lib, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        httpcheck: yes
        lighttpd: no
        nginx: yes
        phpfpm: no
        web_log: yes
        whoisquery: no
    '';
    "netdata/go.d/httpcheck.conf".text = builtins.readFile ./go.d/httpcheck.conf;
    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/web_log.conf".text = builtins.readFile ./go.d/web_log.conf;

    "netdata/python.d.conf".text = ''
      example: no
      httpcheck: no
      logind: yes
      nginx: no
      web_log: no
    '';
  };
}
