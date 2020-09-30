{ config, lib, pkgs, ... }:

with lib;

{
  services.nginx = {
    upstreams."thefractal-space" = {
      servers."web-2.vrt.fsn.lama-corp.space:8002" = {};
    };

    virtualHosts."thefractal.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-thefractal.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-thefractal.space.log;
      '';
      locations = {
        "/" = {
          extraConfig = ''
            uwsgi_pass thefractal-space;
            include ${config.services.nginx.package}/conf/uwsgi_params;
          '';
        };
      };
    };
  };
}
