{ config, lib, pkgs, ... }:

with lib;

{
  services.nginx = {
    upstreams."scoreboard-seedbox-cri-risson-space" = {
      servers."web-2.containers:8004" = {};
    };

    virtualHosts."scoreboard-seedbox-cri.risson.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 25M;
        access_log ${config.services.nginx.logsDirectory}/access-scoreboard-seedbox-cri.risson.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-scoreboard-seedbox-cri.risson.space.log;
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
