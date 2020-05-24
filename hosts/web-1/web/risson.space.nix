{ pkgs, lib, ... }:

let
  port = 8004;

  # We need to use fetchgit as Hugo build system requires a git repository
  src = import (pkgs.fetchgit {
    url = "https://gitlab.com/risson/risson.space.git";
    rev = "879ec743c4d3804f2a3b03640100b2ac1b2c5898";
    sha256 = "17k2l2qzdplqyarhzif7qyyzgkqyv45q54c49lc0viqxfm5ybjd4";
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
