{ pkgs, lib, ... }:

let
  port = 8004;

  # We need to use fetchgit as Hugo build system requires a git repository
  src = import (pkgs.fetchgit {
    url = "https://gitlab.com/risson/risson.space.git";
    rev = "f5031f4ad07579f944f060b948ae1e3aaf9726e9";
    sha256 = "01jz11gfcbdpqjsaq8zmrjlm2qiyfbgl841i8pm6agd89nkm88sw";
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
