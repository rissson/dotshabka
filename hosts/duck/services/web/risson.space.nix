{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."risson.space" = {
    serverAliases = [
      "www.risson.space"
      "risson.me"
      "www.marcerisson.space"
      "risson.rocks"
      "www.risson.rocks"
      "risson.tech"
      "www.risson.tech"
    ];
    forceSSL = true;
    sslCertificate = /srv/certs/default.pem;
    sslCertificateKey = /srv/certs/default.key;
    root = "/srv/http/risson.space/public";
    locations = {
      "/" = {
        index = "index.html index.htm";
      };
    };
  };
}
