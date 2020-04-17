{ config, lib, pkgs, ... }:

with lib;

let
  dotshabka = import <dotshabka> {};
in {
  systemd.services.thefractal-space = {
    enable = true;
    description = "thefractal.space website";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.python37Packages.gunicorn}/bin/gunicorn \
          --workers 4 \
          --timeout 240 \
          --max-requests 1000 \
          --max-requests-jitter 50 \
          --chdir ${dotshabka.external.risson.nur.thefractalbot-web}/lib/python3.7/site-packages \
          --bind unix:/srv/http/thefractal.space/thefractal.space.sock \
          thefractalbot_web.app:app
    '';
    serviceConfig = {
      WorkingDirectory = "/srv/http/thefractal.space";
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
      User = "nginx";
    };
    environment = {
      FRACTALS_DIR = "/srv/http/thefractal.space/imgs";
    };
  };

  services.nginx.virtualHosts."thefractal.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-thefractal.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://unix:/srv/http/thefractal.space/thefractal.space.sock";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
