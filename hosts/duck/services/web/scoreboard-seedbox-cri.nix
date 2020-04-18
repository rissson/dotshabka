{ lib, ... }:

with lib;

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};
in {
  systemd.services.scoreboard-seedbox-cri = mkIf (builtins.pathExists /srv/http/scoreboard-seedbox-cri) {
    enable = true;
    description = "thefractal.space website";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = let
      djangoEnv = nixpkgs.poetry2nix.mkPoetryEnv {
        projectDir = "/srv/http/scoreboard-seedbox-cri";

        overrides = nixpkgs.poetry2nix.overrides.withDefaults (
          self: super: {
            python-jose = super.python-jose.overridePythonAttrs(old: {
              postPatch = ''
                substituteInPlace setup.py --replace "'pytest-runner'," ""
                substituteInPlace setup.py --replace "'pytest-runner'" ""
              '';
            });
            social-auth-backend-epita = super.social-auth-backend-epita.overridePythonAttrs(old: {
              postPatch = ''
                substituteInPlace setup.py --replace "'social-auth-core[openidconnect]'," ""
              '';
            });
          }
        );
      };
    in ''
      ${djangoEnv}/bin/gunicorn \
          --workers 4 \
          --max-requests 1000 \
          --max-requests-jitter 50 \
          --chdir /srv/http/scoreboard-seedbox-cri \
          --bind unix:/srv/http/scoreboard-seedbox-cri/scoreboard-seedbox-cri.sock \
          conf.wsgi:application
    '';
    serviceConfig = {
      WorkingDirectory = "/srv/http/scoreboard-seedbox-cri";
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
      User = "nginx";
    };
    environment = {
      DJANGO_IGNORE_MISSING_ENV = "1";
    };
  };

  security.acme.certs."scoreboard-seedbox-cri.risson.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."scoreboard-seedbox-cri.risson.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 25M;
      access_log /var/log/nginx/access-scoreboard-seedbox-cri.risson.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://unix:/srv/http/scoreboard-seedbox-cri/scoreboard-seedbox-cri.sock";
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
