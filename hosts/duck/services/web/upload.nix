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
    sslCertificate = /srv/certs/default.pem;
    sslCertificateKey = /srv/certs/default.key;
    root = "/home/risson/upload";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
