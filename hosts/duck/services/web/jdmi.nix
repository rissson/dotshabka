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
    sslCertificate = /srv/certs/default.pem;
    sslCertificateKey = /srv/certs/default.key;
    root = "/srv/http/jdmi/site";
    locations = {
      "/" = {
        index = "index.html";
      };
    };
  };
}
