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

          local = import "${toString ./.}/${hostName}/configuration.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        lib.concat flakeModules [
          impermanence.nixosModules.impermanence
          core
          global
          overrides
          local
        ];
    };

  hosts = lib.genAttrs [
    "hedgehog"
  ]
    config;
in
hosts
