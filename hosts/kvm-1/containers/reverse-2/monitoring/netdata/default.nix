{ config, lib, pkgs, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        nginx: yes
        web_log: yes
    '';

    "netdata/go.d/nginx.conf".text = builtins.readFile ./go.d/nginx.conf;
    "netdata/go.d/web_log.conf".text = builtins.readFile ./go.d/web_log.conf;
  };
}
