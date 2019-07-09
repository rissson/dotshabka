{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."lama-corp.space" = {
    serverAliases = [
      "www.lama-corp.space"
    ];
    default = true;
    forceSSL = true;
    sslCertificate = /srv/certs/default.pem;
    sslCertificateKey = /srv/certs/default.key;
    root = "/srv/http/lama-corp.space";
    locations = {
      "/" = {
        index = "index.php index.html index.htm";
      };
    };
  };
}
