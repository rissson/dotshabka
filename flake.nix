{
  # name = "soxincfg";

  description = "Lama Corp. infrastructure configurations.";

  inputs = rec {
    nixos.url = "nixpkgs/nixos-20.09";
    nixpkgs.url = "nixpkgs/master";
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
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixos, nixpkgs, home-manager, soxin, impermanence, nixos-hardware, nur, futils, sops-nix, deploy-rs } @ inputs:
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
        nixpkgs = pkgImport nixpkgs system;
      };

      multiSystemOutputs = eachDefaultSystem (system:
      let
          pkgset' = pkgset system;
          pkgs = pkgset'.nixpkgs;
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
              deploy-rs.packages.${system}.deploy-rs
            ];
          };

          packages = self.lib.overlaysToPkgs self.overlays pkgs;
        }
      );

      outputs = {
        lib = import ./lib { inherit lib; };

        vars = import ./vars;

        overlay = self.overlays.packages;

        overlays = {
          packages = import ./pkgs;
          flannel = import ./overlays/flannel.nix;
        };

        nixosModules = (import ./modules) // {
          profiles = import ./profiles;
          soxin = import ./soxin/soxin.nix;
          soxincfg = import ./modules/soxincfg.nix;
        };

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

        deploy = {
          nodes =
            builtins.mapAttrs
            (n: v: {
              hostname = v.config.networking.fqdn;
              profiles.system = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos v;
              };
            })
            (removeAttrs self.nixosConfigurations [ "goat" "hedgehog" ]);
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
