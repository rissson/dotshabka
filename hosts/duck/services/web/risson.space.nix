{ config, lib, pkgs, ... }:
{
  security.acme.certs."risson.space".email = "caa@lama-corp.space";
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
    extraConfig = ''
      access_log /var/log/nginx/access-risson.space.log netdata;
    '';
    root = "/srv/http/risson.space/prod";
    locations = {
      "/" = {
        index = "index.html index.htm";
      };
    };
  };

  security.acme.certs."staging.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."staging.risson.space" = {
    serverAliases = [
      "staging.risson.me"
      "staging.marcerisson.space"
      "staging.risson.rocks"
      "staging.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/risson.space/staging";
    locations = {
      "/" = {
        index = "index.html index.htm";
      };
    };
  };

  security.acme.certs."dev.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."dev.risson.space" = {
    serverAliases = [
      "dev.risson.me"
      "dev.marcerisson.space"
      "dev.risson.rocks"
      "dev.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/risson.space/dev";
    locations = {
      "/" = {
        index = "index.html index.htm";
      };
    };
  };
}
