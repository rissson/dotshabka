{ pkgs, lib, ... }:

let
  port = 8004;

  # We need to use fetchgit as Hugo build system requires a git repository
  src = import (pkgs.fetchgit {
    url = "https://gitlab.com/risson/risson.space.git";
    rev = "351654f4c5488d50a354a9a72a4ebc5c8aa8d203";
    sha256 = "09d6ylhdlx10wya0xwsfxqj1nik4zhp5fyak9kzq0fy5sww404n6";
    leaveDotGit = true;
    deepClone = true;
  }) { baseURL = "https://risson.space/"; };
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."risson.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "${src}";
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ =404";
    };
    extraConfig = ''
      error_page 404 /404.html;
    '';
  };
}
