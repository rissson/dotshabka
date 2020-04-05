{ config, lib, pkgs, ... }:

with lib;

{
  systemd.services.cAtCDC = mkIf (builtins.pathExists /srv/http/cAtCDC) {
    enable = true;
    description = "cAtCDC website";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = let
      nixpkgs = import (builtins.fetchTarball {
        name = "nixpkgs-unstable-cAtCDC";
        url = "https://github.com/nixos/nixpkgs/archive/c9bf23e6583164033d0cdce83825f3bb288de9b7.tar.gz";
        sha256 = "1v2zw6gqq3z1hwgwli7kihsqffp0xcim6a1y3dszg1wca1jqjq5w";
      }) {};
      djangoEnv = nixpkgs.poetry2nix.mkPoetryEnv {
        projectDir = /srv/http/cAtCDC;
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
          --chdir /srv/http/cAtCDC \
          --bind unix:/srv/http/cAtCDC/cAtCDC.sock \
          conf.wsgi:application
    '';
    serviceConfig = {
      WorkingDirectory = /srv/http/cAtCDC;
      Restart = "always";
      RestartSec = "10s";
      StartLimitInterval = "1min";
      User = "nginx";
    };
    environment = {
      DJANGO_IGNORE_MISSING_ENV = "1";
      USE_S3 = "1";
    };
  };

  services.nginx.virtualHosts."cats.acdc.epita.fr" = {
    serverAliases = [
      "cats.acdc.risson.space"
      "cats.acdc.risson.me"
      "cats.acdc.marcerisson.space"
      "cats.acdc.risson.rocks"
      "cats.acdc.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://unix:/srv/http/cAtCDC/cAtCDC.sock";
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
