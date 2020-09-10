{ self
, nixpkgs-unstable
, nixpkgs-stable
, shabka
, nixos-hardware
, lib
, pkgset
, system
, utils
, ...
}@inputs:

let
  inherit (utils) recImport;
  inherit (builtins) attrValues removeAttrs;
  inherit (pkgset) osPkgs pkgs;

  config = hostName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
      };

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            networking.hostName = hostName;
            nix.nixPath = let path = toString ../.; in
              [
                "nixpkgs=${nixpkgs-unstable}"
                "nixos=${nixpkgs-stable}"
                "nixos-config=${path}/configuration.nix"
                "nixpkgs-overlays=${path}/overlays"
              ];

            nixpkgs = {
              pkgs = osPkgs;
              config.allowBroken = true;
            };

            nix.registry = {
              nixos.flake = nixpkgs-stable;
              shabka.flake = shabka;
              dotshabka.flake = self;
              nixpkgs.flake = nixpkgs-unstable;
            };
          };

          overrides = {
            # use latest systemd
            #systemd.package = pkgs.systemd;

            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix pkgs;

                overlay = pkg: final: prev: {
                  "${pkg.pname}" = pkg;
                };
              in
              map overlay override;
          };

          local = import "${toString ./.}/${hostName}/configuration.nix";

          shabkaModules = attrValues shabka.nixosModules;

          # Everything in `./modules/list.nix`.
          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        shabkaModules ++ flakeModules ++ [ core global local overrides ];

    };

  hosts = lib.genAttrs [
    "goat"
    #"hedgehog"
  ] config;
in
hosts
