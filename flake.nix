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
    nixops.url = "nixops";
  };

  outputs = { self, nixos, master, home-manager, soxin, impermanence, nixos-hardware, nur, futils, nixops } @ inputs:
    let
      inherit (nixos) lib;
      inherit (nixos.lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system:
        import pkgs {
          inherit system;
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
            name = "soxincfg";

            buildInputs = [
              nixops.defaultPackage.${system}
              pkgs.git
              pkgs.morph
              pkgs.nixpkgs-fmt
              pkgs.pre-commit
            ];
          };
        }
      );

      outputs = {
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

        nixopsConfigurations.default =
          let
            system = "x86_64-linux";
            pkgset' = pkgset system;
          in
        {
          nixpkgs = nixos;
        } // (import ./hosts (
          lib.recursiveUpdate inputs {
            inherit lib system;
            pkgset = pkgset';
            deployment = true;
          }
        ));
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
