{ lib
, system
, pkgset
, self
, nixos
, nixpkgs
, home-manager
, soxin
, impermanence
, nixos-hardware
, nur
, futils
, sops-nix
, deploy-rs
}:

let
  config = path:
    let
      hostName = lib.lists.last (lib.splitString "/" path);
    in
    soxin.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixos-hardware;
        inherit (pkgset) nixpkgs;
        soxincfg = self;
        userName = "risson"; # TODO: extract this per-host
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
                "nixpkgs=${nixpkgs}"
              ];

            nixpkgs = { pkgs = pkgset.nixos; };

            nix.registry = {
              nixos.flake = nixos;
              nixpkgs.flake = nixpkgs;
              soxincfg.flake = self;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
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

          local = import "${toString ./.}/${path}/configuration.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "soxincfg" ]);

        in
        lib.concat flakeModules [
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          sops-fix

          core
          global
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
    "bar/cuckoo"
    "bar/nas-1"
    "fsn/k8s/master-11"
    "fsn/k8s/master-12"
    "fsn/k8s/master-13"
    "fsn/k8s/worker-11"
    "fsn/k8s/worker-12"
    "fsn/k8s/worker-13"
    "fsn/kvm-2"
    "fsn/mail-1"
    "fsn/pine"
    "p13/rogue"
    "par/edge-1"
    "rsn/goat"
    "rsn/hedgehog"
    "vha/edge-2"
  ]
    config;
in
hosts
