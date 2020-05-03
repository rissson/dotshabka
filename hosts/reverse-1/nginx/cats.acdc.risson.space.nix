{ config, lib, pkgs, ... }:

with lib;

{
  services.nginx.upstreams."cats-acdc-risson-space" = {
    servers."web-1.vrt.fsn.lama-corp.space:8005" = {};
  };

  services.nginx.virtualHosts."cats.acdc.risson.space" = {
    serverAliases = [ "cats.acdc.epita.fr" ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-cats.acdc.risson.space.log netdata;
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
}
