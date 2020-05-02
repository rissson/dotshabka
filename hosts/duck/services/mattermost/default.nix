{ config, pkgs, lib, ... }:

with lib;

let
  nixpkgs =
    import (import <shabka> { }).external.nixpkgs.release-unstable.path { };
  cfg = config.services.mattermost;
  database =
    "postgres://${cfg.localDatabaseUser}:${cfg.localDatabasePassword}@localhost:5432/${cfg.localDatabaseName}?sslmode=disable&connect_timeout=10";
in {
  nixpkgs.overlays = [
    (self: super: {
      mattermost = pkgs.callPackage ./package.nix {
        inherit (nixpkgs) stdenv fetchurl fetchFromGitHub buildEnv;
        buildGoPackage = nixpkgs.buildGo114Package;
      };
    })
  ];

  systemd.services.mattermost.serviceConfig.ExecStart = mkForce
    (pkgs.writeTextFile {
      name = "unit-script-mattermost-start";
      executable = true;
      text = ''
        #! ${pkgs.runtimeShell} -e
        ${pkgs.mattermost}/bin/mattermost server -c '${database}'
      '';
    });

  services.mattermost = {
    enable = true;
    listenAddress = ":19065";
    localDatabaseCreate = true;
    localDatabaseName = "mattermost";
    localDatabaseUser = "mattermost";
    mutableConfig = false;
    siteName = "Chat | Lama Corp.";
    siteUrl = "https://chat.lama-corp.space";
    statePath = "/srv/mattermost";
    # Configuration is hosted by the database.
  };

  security.acme.certs."chat.lama-corp.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."chat.lama-corp.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-chat.lama-corp.space.log netdata;
    '';
    locations = {
      "~ /api/v[0-9]+/(users/)?websocket$" = {
        proxyPass = "http://localhost:19065";
        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          client_max_body_size 50M;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Frame-Options SAMEORIGIN;
          proxy_buffers 256 16k;
          proxy_buffer_size 16k;
          client_body_timeout 60;
          send_timeout 300;
          lingering_timeout 5;
          proxy_connect_timeout 90;
          proxy_send_timeout 300;
          proxy_read_timeout 90s;
        '';
      };
      "/" = {
        proxyPass = "http://localhost:19065";
        # TODO: enable cache?
        extraConfig = ''
          client_max_body_size 50M;
          proxy_set_header Connection "";
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Frame-Options SAMEORIGIN;
          proxy_buffers 256 16k;
          proxy_buffer_size 16k;
          proxy_read_timeout 600s;
          #proxy_cache mattermost_cache;
          #proxy_cache_revalidate on;
          #proxy_cache_min_uses 2;
          #proxy_cache_use_stale timeout;
          #proxy_cache_lock on;
          #proxy_http_version 1.1;
        '';
      };
    };
  };
}
