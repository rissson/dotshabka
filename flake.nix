{
  description = "Lama Corp. Infrastructure configurations";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-20.03";
    shabka.url = "/home/risson/code/shabka";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = inputs@{ self, nixpkgs-unstable, nixpkgs-stable, shabka, nixos-hardware }:
    let
      inherit (builtins) attrNames attrValues readDir;
      inherit (nixpkgs-stable) lib;
      inherit (lib) removeSuffix recursiveUpdate genAttrs filterAttrs;
      inherit (utils) pathsToImportedAttrs;

      utils = import ./lib/utils.nix { inherit lib; };

      system = "x86_64-linux";

      pkgImport = pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = {
        osPkgs = pkgImport nixpkgs-stable;
        pkgs = pkgImport nixpkgs-unstable;
      };

      homeList = import ./home/risson/list.nix;
      homeAttrs = pathsToImportedAttrs homeList;

    in
    with pkgset;
    {
      nixosConfigurations =
        import ./hosts (recursiveUpdate inputs {
          inherit lib pkgset system utils;
        }
      );

      vars = import ./data { };

      devShell."${system}" = (import ./shell.nix { inherit pkgs; });

      overlay = import ./pkgs;

      overlays =
        let
          overlayDir = ./overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (attrNames (readDir overlayDir));
        in
        pathsToImportedAttrs overlayPaths;

      packages."${system}" =
        let
          packages = self.overlay osPkgs osPkgs;
          overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
          overlayPkgs =
            genAttrs
              (attrNames overlays)
              (name: (overlays."${name}" osPkgs osPkgs)."${name}");
        in
        recursiveUpdate packages overlayPkgs;

      nixosModules =
        let
          # allow the use of NixOS config in home-manager configuration
          homeModule = { config, ... }: {
            options.home-manager.users = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submoduleWith {
                modules = homeList;
              });
            };
          };

          # NixOS modules
          moduleList = import ./modules/list.nix;
          modulesAttrs = pathsToImportedAttrs moduleList;

          # profiles
          profilesList = import ./profiles/list.nix;
          profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };
        in
        recursiveUpdate
          (recursiveUpdate modulesAttrs profilesAttrs)
          { inherit homeModule; };

        homeModules = {
          inherit homeAttrs;
        };
    };
}
