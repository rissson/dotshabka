{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."lama-corp.space" = {
    serverAliases = [
      "www.lama-corp.space"
    ];
    default = true;
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-lama-corp.space.log netdata;
    '';
    root = "/srv/http/lama-corp.space";
    locations = {
      "/" = {
        index = "index.php index.html index.htm";
      };
    };
  };
}
