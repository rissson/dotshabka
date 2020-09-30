{ config, lib, pkgs, ... }:

with lib;

{
  services.nginx = {
    upstreams."cats-acdc-risson-space" = {
      servers."web-2.vrt.fsn.lama-corp.space:8005" = {};
    };

    virtualHosts."cats.acdc.risson.space" = {
      serverAliases = [ "cats.acdc.epita.fr" ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-cats.acdc.risson.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-cats.acdc.risson.space.log;
      '';
      locations = {
        "/" = {
          extraConfig = ''
            uwsgi_pass cats-acdc-risson-space;
            include ${config.services.nginx.package}/conf/uwsgi_params;
          '';
        };
      };
    };
  };
}
