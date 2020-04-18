{ config, lib, pkgs, ... }:
{
  security.acme.certs."acdc.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."acdc.risson.space" = {
    serverAliases = [
      "acdc.risson.me"
      "acdc.marcerisson.space"
      "acdc.risson.rocks"
      "acdc.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/acdc";
    extraConfig = ''
      access_log /var/log/nginx/access-acdc.risson.space.log netdata;
    '';
    locations = {
      "/photos" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
