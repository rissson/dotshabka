{ config, lib, pkgs, ... }:

with lib;

let
  port = 8002;

  nixpkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-thefractal-space";
    url = "https://github.com/NixOS/nixpkgs-channels/archive/c9bf23e6583164033d0cdce83825f3bb288de9b7.tar.gz";
    sha256 = "1v2zw6gqq3z1hwgwli7kihsqffp0xcim6a1y3dszg1wca1jqjq5w";
  }) {};

  thefractalspaceSrc = pkgs.fetchFromGitLab {
    owner = "ddorn";
    repo = "thefractal.space";
    rev = "271fc63de6d4149fe79ece6fc9b63916e5b6bb04";
    sha256 = "1iwhamgni9yfyfn0d35qb85mgavh2h1hi4zs9raqm8l4k8qxfqng";
  };
  thefractalspace = import thefractalspaceSrc { };
  thefractalspaceEnv = import thefractalspaceSrc { mkEnv = true; };
in {
  networking.firewall.allowedTCPPorts = [ port ];

  services.uwsgi.instance.vassals = {
    "thefractalspace" = {
      type = "normal";
      pyhome = "${thefractalspaceEnv}";
      env = [
        "PATH=${thefractalspace.python}/bin"
        "PYTHONPATH=${thefractalspace}/${thefractalspace.python.sitePackages}"
        "FRACTALS_DIR=/var/cache/thefractal.space"
      ];
      wsgi = "thefractalspace.app:app";
      socket = ":${toString port}";
      master = true;
      processes = 2;
      vacuum = true;
      chdir = "/var/cache/thefractal.space";
    };
  };
}
