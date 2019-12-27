{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."jdmi.risson.space" = {
    serverAliases = [
      "jdmi.risson.me"
      "jdmi.marcerisson.space"
      "jdmi.risson.rocks"
      "jdmi.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/jdmi/site";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
