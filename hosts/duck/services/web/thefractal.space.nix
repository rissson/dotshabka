{ lib, ... }:

with lib;

let
  shabka = import <shabka> { };
  nixpkgs = import shabka.external.nixpkgs.release-unstable.path { };
in {
  systemd.services.thefractal-space =
    mkIf (builtins.pathExists /srv/http/thefractal.space) {
      enable = true;
      description = "thefractal.space website";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = let
        flaskEnv = nixpkgs.poetry2nix.mkPoetryEnv {
          projectDir = "/srv/http/thefractal.space";

          overrides = nixpkgs.poetry2nix.overrides.withDefaults (self: super: {
            kivy = null;
            kivymd = null;
            kivy-garden = null;
            colour = super.colour.overridePythonAttrs
              (old: { buildInputs = [ nixpkgs.python3Packages.d2to1 ]; });
          });
        };
      in ''
        ${flaskEnv}/bin/gunicorn \
            --workers 4 \
            --timeout 240 \
            --max-requests 1000 \
            --max-requests-jitter 50 \
            --chdir /srv/http/thefractal.space \
            --bind unix:/srv/http/thefractal.space/thefractal.space.sock \
            thefractalspace.app:app
      '';
      serviceConfig = {
        WorkingDirectory = "/srv/http/thefractal.space";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
        User = "nginx";
      };
      environment = { FRACTALS_DIR = "/srv/http/thefractal.space/imgs"; };
    };

  services.nginx.virtualHosts."thefractal.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-thefractal.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass =
          "http://unix:/srv/http/thefractal.space/thefractal.space.sock";
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
