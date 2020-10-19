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
, nixops
, deployment ? false
}:

let
  modules = hostName:
    let
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

      local = import "${toString ./.}/${hostName}/configuration.nix";

    in
    [
      impermanence.nixosModules.impermanence
      global
      local
    ];

  specialArgs = {
    inherit nixos-hardware;
  };

  config = hostName:
    soxin.lib.nixosSystem {
      inherit system specialArgs;

      modules = modules hostName;
    };

  hosts = lib.genAttrs [
    "hedgehog"
  ]
    config;
in
  if !deployment then hosts else {
    hedgehog = {
      _module.args = specialArgs;
      imports = modules "hedgehog";
    };
  }
