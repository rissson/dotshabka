{ config, lib, ... }:

with lib;

{
  services.netdata.python = {
    enable = true;
    extraPackages = ps: [
      ps.psycopg2
    ];
  };

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        httpcheck: yes
        nginx: yes
        phpfpm: yes
        web_log: yes
    '';
    "netdata/go.d/httpcheck.conf".text = builtins.readFile ./go.d/httpcheck.conf;
    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/phpfpm.conf".text = builtins.readFile ./go.d/phpfpm.conf;
    "netdata/go.d/portcheck.conf".text = builtins.readFile ./go.d/portcheck.conf;
    "netdata/go.d/unbound.conf".text = builtins.readFile ./go.d/unbound.conf;
    "netdata/go.d/web_log.conf".text = builtins.readFile ./go.d/web_log.conf;
    "netdata/go.d/x509check.conf".text = builtins.readFile ./go.d/x509check.conf;

    "netdata/python.d.conf".text = ''
      example: no
      httpcheck: no
      logind: yes
      nginx: no
      phpfpm: no
      web_log: no
    '';
  };
}
