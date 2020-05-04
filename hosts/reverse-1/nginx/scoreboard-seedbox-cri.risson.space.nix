{ config, lib, pkgs, ... }:

with lib;

{
  services.nginx = {
    upstreams."scoreboard-seedbox-cri-risson-space" = {
      servers."web-2.vrt.fsn.lama-corp.space:8004" = {};
    };

    virtualHosts."scoreboard-seedbox-cri.risson.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 25M;
        access_log /var/log/nginx/access-scoreboard-seedbox-cri.risson.space.log netdata;
      '';
      locations = {
        "/" = {
          extraConfig = ''
            uwsgi_pass scoreboard-seedbox-cri-risson-space;
            include ${config.services.nginx.package}/conf/uwsgi_params;
          '';
        };
      };
    };
  };
}
