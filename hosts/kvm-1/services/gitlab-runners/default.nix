{ config, pkgs, lib, ... }:

with lib;

{
  disabledModules = [ "services/continuous-integration/gitlab-runner.nix" ];

  imports = [ ./gitlab-runner.nix ];

  services.gitlab-runner = {
    enable = false;
    concurrent = 4;
    services = {
      # runner for dotshabka
      # can be used for building via nix
      lamacorp-nix = {
        registrationConfigFile = "/srv/secrets/gitlab-runner-dotshabka";
        dockerImage = "nix";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        dockerDisableCache = true;
        preBuildScript = pkgs.writeScript "setup-container" ''
          mkdir -p -m 0755 /nix/var/log/nix/drvs
          mkdir -p -m 0755 /nix/var/nix/gcroots
          mkdir -p -m 0755 /nix/var/nix/profiles
          mkdir -p -m 0755 /nix/var/nix/temproots
          mkdir -p -m 0755 /nix/var/nix/userpool
          mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
          mkdir -p -m 1777 /nix/var/nix/profiles/per-user
          mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
          mkdir -p -m 0700 "$HOME/.nix-defexpr"

          . ${pkgs.nix}/etc/profile.d/nix.sh

          ${pkgs.nix}/bin/nix-env -i ${
            concatStringsSep " " (with pkgs; [ nix cacert git openssh cachix ])
          }

          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
          ${pkgs.nix}/bin/nix-channel --update nixpkgs
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH =
            "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE =
            "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
        tagList = [ "nix-store" ];
      };
      lamacorp-default = {
        registrationConfigFile = "/srv/secrets/gitlab-runner-dotshabka";
        dockerImage = "nix";
      };
      risson-epita-chess = {
        registrationConfigFile = "/srv/secrets/gitlab-runner-epita-chess";
        dockerImage = "registry.gitlab.com/pierre.kelbert/docker-archlinux-criterion:9ff8657845e21a4493f62e67540dcb8c13994577";
      };
    };
  };
}
