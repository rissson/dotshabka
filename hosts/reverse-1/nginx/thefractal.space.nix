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
        access_log /var/log/nginx/access-thefractal.space.log netdata;
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
