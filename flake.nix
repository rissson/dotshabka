{
  # name = "soxincfg";

  description = "Lama Corp. infrastructure configurations.";

  inputs = {
    nixos.url = "nixpkgs/nixos-20.09";
    master.url = "nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
    };
    soxin = {
      url = "git+file:///home/risson/code/soxin";
      inputs = {
        nixpkgs.follows = "nixos";
        home-manager.follows = "home-manager";
      };
    };
    impermanence = {
      url = "github:danieldk/impermanence/flake";
      inputs.nixpkgs.follows = "nixos";
    };
    nixos-hardware.url = "nixos-hardware";
    nur.url = "nur";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixos, master, home-manager, soxin, impermanence, nixos-hardware, nur, futils } @ inputs:
    let
      inherit (nixos) lib;
      inherit (nixos.lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = system: {
        nixos = pkgImport nixos system;
        master = pkgImport master system;
      };

      multiSystemOutputs = eachDefaultSystem (system:
      let
          pkgset' = pkgset system;
          pkgs = pkgset'.master;
          osPkgs = pkgset'.nixos;
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              morph
              nixpkgs-fmt
              pre-commit
            ];
          };

          packages = self.lib.overlaysToPkgs self.overlays osPkgs;
        }
      );

      outputs = {
        lib = import ./lib { inherit lib; };

        vars = import ./vars;

        nixosConfigurations =
          let
            system = "x86_64-linux";
            pkgset' = pkgset system;
          in
          import ./hosts (
            lib.recursiveUpdate inputs {
              inherit lib system;
              pkgset = pkgset';
            }
          );

        nixosModules = (import ./modules) // {
          profiles = self.lib.pathsToImportedAttrs (import ./profiles/list.nix);
          soxincfg = import ./modules/soxincfg.nix;
        };

        overlay = import ./pkgs;

        overlays =
          let
            overlayDir = ./overlays;
            fullPath = name: overlayDir + "/${name}";
            overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          in
          self.lib.pathsToImportedAttrs overlayPaths;
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
