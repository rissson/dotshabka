{ pkgs, lib, ... }:

let
  port = 8004;

  # We need to use fetchgit as Hugo build system requires a git repository
  src = import (pkgs.fetchgit {
    url = "https://gitlab.com/risson/risson.space.git";
    rev = "644d71cbc4d6577050b7cf37f1fa09bf1b8f1f5d";
    sha256 = "1g9560mssgqjkcyg6z2asmaqlj5x0zxyz5ig3vzg8nd9gqwixmwy";
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
