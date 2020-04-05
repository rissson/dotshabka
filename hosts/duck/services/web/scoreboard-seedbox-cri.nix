{ config, lib, pkgs, ... }:
{
  # TODO: migrate this to not using Docker anymore
  services.nginx.virtualHosts."scoreboard-seedbox-cri.risson.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 25M;
    '';
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:9040";
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host $http_host;
        '';
      };
      "/static" = {
        root = "/home/risson/seedbox-cri-scoreboard";
      };
    };
  };
}
