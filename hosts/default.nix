{ lib
, system
, pkgset
, self
, nixos
, master
, home-manager
, soxin
, impermanence
, nixos-hardware
, nur
, futils
, sops-nix
}:

let
  config = hostName:
    soxin.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixos-hardware;
        soxincfg = self;
      };

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            networking.hostName = hostName;
            nix.nixPath =
              let
                path = toString ../.;
              in
              [
                "nixos=${nixos}"
                "nixpkgs=${master}"
                "nixpkgs-overlays=${path}/overlays"
              ];

            nixpkgs = { pkgs = pkgset.nixos; };

            nix.registry = {
              nixos.flake = nixos;
              nixpkgs.flake = master;
              soxincfg.flake = self;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          overrides = {
            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix pkgset.master;

                overlay = pkg: _: _: {
                  "${pkg.pname}" = pkg;
                };
              in
              lib.concat [ nur.overlay ] (map overlay override);
          };

          sops-fix = { config, pkgs, lib, ... }: {
            system.activationScripts.setup-secrets =
              let
                sops-install-secrets = sops-nix.packages.x86_64-linux.sops-install-secrets;
                manifest = builtins.toFile "manifest.json" (builtins.toJSON {
                  secrets = builtins.attrValues config.sops.secrets;
                  # Does this need to be configurable?
                  secretsMountPoint = "/run/secrets.d";
                  symlinkPath = "/run/secrets";
                  inherit (config.sops) gnupgHome sshKeyPaths;
                });

                checkedManifest = pkgs.runCommandNoCC "checked-manifest.json" {
                  nativeBuildInputs = [ sops-install-secrets ];
                } ''
                  sops-install-secrets -check-mode=${if config.sops.validateSopsFiles then "sopsfile" else "manifest"} ${manifest}
                  cp ${manifest} $out
                '';
              in
              lib.mkForce (lib.stringAfter [ "users" "groups" ] ''
                echo setting up secrets...
                export PATH=$PATH:${pkgs.gnupg}/bin:${pkgs.gnupg}/sbin
                SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg ${sops-install-secrets}/bin/sops-install-secrets ${checkedManifest}
              '');
          };

          local = import "${toString ./.}/${hostName}/configuration.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "soxincfg" ]);

        in
        lib.concat flakeModules [
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          sops-fix

          core
          global
          overrides
          local
          ({ config, ... }: {
            options.home-manager.users = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = flakeModules;
              });
            };
          })
        ];
    };

  hosts = lib.genAttrs [
    "hedgehog"
    "goat"
    "kvm-2"
    "nas-1"
  ]
    config;
in
hosts
