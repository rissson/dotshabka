{ config, lib, pkgs, ... }:
{
  security.acme.certs."upload.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."upload.risson.space" = {
    serverAliases = [
      "upload.risson.me"
      "upload.marcerisson.space"
      "upload.risson.rocks"
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
