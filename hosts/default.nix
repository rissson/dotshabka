{ lib
, system
, pkgset
, self
, nixpkgs
, nixpkgsUnstable
, nixpkgsMaster
, home-manager
, soxin
, impermanence
, nixos-hardware
, nur
, futils
, sops-nix
, deploy-rs
, dns
}:

let
  config = path:
    let
      hostName = lib.lists.last (lib.splitString "/" path);
    in
    soxin.lib.nixosSystem {
      inherit system;

      globalSpecialArgs = {
        inherit nixos-hardware dns;
        inherit (pkgset) nixpkgsUnstable nixpkgsMaster;
        soxincfg = self;
        userName = "risson"; # TODO: extract this per-host
      };

      globalModules = builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "soxincfg" ]);

      nixosModules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            networking.hostName = hostName;
            nix.nixPath =
              let
                path = toString ../.;
              in
              [
                "nixpkgs=${nixpkgs}"
                "nixpkgs-unstable=${nixpkgsUnstable}"
                "nixpkgs-master=${nixpkgsMaster}"
                "soxin=${soxin}"
                "soxincfg=${self}"
              ];

            nixpkgs = {
              inherit (pkgset) pkgs;
            };

            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixpkgsUnstable.flake = nixpkgsUnstable;
              nixpkgsMaster.flake = nixpkgsMaster;
              soxin.flake = soxin;
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
        in
        [
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          sops-fix

          core
          global
          local
        ];
    };

  hosts = lib.genAttrs [
    "bar/cuckoo"
    "bar/nas-1"
    "fsn/k8s/master-11"
    "fsn/k8s/master-12"
    "fsn/k8s/master-13"
    "fsn/kvm-2"
    "fsn/mail-1"
    "fsn/pine"
    "p13/gate"
    "p13/rogue"
    "p13/storj-1"
    "pvl/edge-1"
    "rsn/goat"
    "rsn/hedgehog"
    "avh/edge-2"
  ]
    config;
in
hosts
