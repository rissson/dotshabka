{ config, lib, pkgs, ... }:
{
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
    locations = {
      "/photos" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
