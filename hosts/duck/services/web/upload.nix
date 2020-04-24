{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."upload.risson.space" = {
    serverAliases = [
      "upload.risson.me"
      "upload.marcerisson.space"
      "upload.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-upload.risson.space.log netdata;
    '';
    root = "/home/risson/upload";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
