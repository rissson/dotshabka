{ config, lib, pkgs, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        nginx: yes
        phpfpm: yes
        web_log: yes
    '';
    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/phpfpm.conf".text = builtins.readFile ./go.d/phpfpm.conf;
    "netdata/go.d/portcheck.conf".text =
      builtins.readFile ./go.d/portcheck.conf;
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
  };
}
