{ lib
, pkgs
, system
, self
, nixpkgs
, soxin
, impermanence
, nixos-hardware
, nur
, ...
} @ args:

let
  config = hostName:
    soxin.lib.nixosSystem {
      inherit system;

      modules =
        let
          global = {
            networking.hostName = hostName;
            nix.nixPath = let path = toString ../.; in
              [
                "nixpkgs=${nixpkgs}"
                "nixos=${nixpkgs}"
              ];

            nixpkgs = {
              inherit pkgs;
              overlays = [ nur.overlay ];
            };

            nix.registry = {
              nixos.flake = nixpkgs;
              nixpkgs.flake = nixpkgs;
              soxin.flake = soxin;
              soxincfg.flake = self;
            };

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${hostName}/configuration.nix";

        in
        [ impermanence.nixosModules.impermanence global local ];

        specialArgs = {
          soxincfg = self;
          nixos-hardware = nixos-hardware;
        };

    };

  hosts = lib.genAttrs [
    # List of hostnames here
    "hedgehog"
  ] config;
in
hosts
