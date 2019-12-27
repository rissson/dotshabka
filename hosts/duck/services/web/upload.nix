{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."upload.risson.space" = {
    serverAliases = [
      "upload.risson.me"
      "upload.marcerisson.space"
      "upload.risson.rocks"
      "upload.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/home/risson/upload";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
