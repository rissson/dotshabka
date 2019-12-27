{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."risson.space" = {
    serverAliases = [
      "www.risson.space"
      "risson.me"
      "www.risson.me"
      "marcerisson.space"
      "www.marcerisson.space"
      "risson.rocks"
      "www.risson.rocks"
      "risson.tech"
      "www.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/risson.space/public";
    locations = {
      "/" = {
        index = "index.html index.htm";
      };
    };
  };
}
