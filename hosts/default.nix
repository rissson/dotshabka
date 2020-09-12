{ lib
, nixos
, master
, pkgset
, shabka
, self
, system
, utils
, ...
}:
let
  inherit (utils) recImport;
  inherit (builtins) attrValues removeAttrs;
  inherit (pkgset) osPkgs pkgs;

  config = hostName:
    shabka.lib.nixosSystem {
      inherit system;

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            networking.hostName = hostName;
            nix.nixPath = let path = toString ../.; in
              [
                "nixpkgs=${master}"
                "nixos=${nixos}"
                "nixos-config=${path}/configuration.nix"
                "nixpkgs-overlays=${path}/overlays"
              ];

            nixpkgs = { pkgs = osPkgs; };

            nix.registry = {
              nixos.flake = nixos;
              nixflk.flake = self;
              nixpkgs.flake = master;
            };
          };

          overrides = {
            # use latest systemd
            systemd.package = pkgs.systemd;

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

          # Everything in `./modules/list.nix`.
          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        flakeModules ++ [ core global local overrides ];

    };

  hosts = lib.genAttrs [
    "goat"
    #"hedgehog"
  ] config;
in
hosts
