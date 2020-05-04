{ config, pkgs, lib, ... }:

with lib;

let
  port = 19065;

  nixpkgs =
    import (import <shabka> { }).external.nixpkgs.release-unstable.path { };
  cfg = config.services.mattermost;
  database =
    "postgres://${cfg.localDatabaseUser}:${cfg.localDatabasePassword}@postgres-1.vrt.fsn.lama-corp.space:5432/${cfg.localDatabaseName}?sslmode=disable&connect_timeout=10";
in {
  nixpkgs.overlays = [
    (self: super: {
      mattermost = pkgs.callPackage ./package.nix {
        inherit (nixpkgs) stdenv fetchurl fetchFromGitHub buildEnv;
        buildGoPackage = nixpkgs.buildGo114Package;
      };
    })
  ];

  networking.firewall.allowedTCPPorts = [ port ];

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
    listenAddress = ":${toString port}";
    localDatabaseCreate = false;
    localDatabaseName = "mattermost";
    localDatabaseUser = "mattermost";
    mutableConfig = false;
    siteName = "Chat | Lama Corp.";
    siteUrl = "https://chat.lama-corp.space";
    statePath = "/srv/mattermost";
    # Configuration is hosted by the database.
  };
}
