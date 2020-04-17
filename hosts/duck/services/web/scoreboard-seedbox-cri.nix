{ config, lib, pkgs, ... }:
{
  # TODO: migrate this to not using Docker anymore
  services.nginx.virtualHosts."scoreboard-seedbox-cri.risson.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 25M;
      access_log /var/log/nginx/access-scoreboard-seedbox-cri.risson.space.log netdata;
    '';
    locations = {
      "/" = {
      extraConfig = ''
        return 200 'This website is currently under active maintenance. Sorry for the interruption :/';
        add_header Content-Type text/plain;
      '';
      };
    };
  };
}
