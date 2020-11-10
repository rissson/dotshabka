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
      url = "github:SoxinOS/soxin";
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
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixos, master, home-manager, soxin, impermanence, nixos-hardware, nur, futils, sops-nix } @ inputs:
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
            sopsPGPKeyDirs = [
              "./vars/sops-keys/hosts"
              "./vars/sops-keys/users"
            ];

            nativeBuildInputs = [
              sops-nix.packages.${system}.sops-pgp-hook
            ];

            buildInputs = with pkgs; [
              git
              sops
              sops-nix.packages.${system}.ssh-to-pgp
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
          profiles = import ./profiles;
          soxin = import ./soxin/soxin.nix;
          soxincfg = import ./modules/soxincfg.nix;
        };

        overlay = import ./pkgs;

        overlays = {
          flannel = import ./overlays/flannel.nix;
        };
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
