{ config, lib, pkgs, ... }:
{
  security.acme.certs."jdmi.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."jdmi.risson.space" = {
    serverAliases = [
      "jdmi.risson.me"
      "jdmi.marcerisson.space"
      "jdmi.risson.rocks"
      "jdmi.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-jdmi.risson.space.log netdata;
    '';
    root = "/srv/http/jdmi/site";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
