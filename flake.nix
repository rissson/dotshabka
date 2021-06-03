{
  # name = "soxincfg";

  description = "Lama Corp. infrastructure configurations.";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "nixos-hardware";
    nur.url = "nur";
    futils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    dns.url = "github:kirelagin/dns.nix";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgsUnstable
    , nixpkgsMaster
    , home-manager
    , soxin
    , impermanence
    , nixos-hardware
    , nur
    , futils
    , sops-nix
    , deploy-rs
    , dns
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system: withOverrides:
        import pkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = (lib.attrValues self.overlays) ++ [
            nur.overlay
            soxin.overlay
          ] ++ (lib.optional withOverrides self.overrides.${system});
        };

      pkgset = system: {
        pkgs = pkgImport nixpkgs system true;
        pkgsUnstable = pkgImport nixpkgsUnstable system false;
        pkgsMaster = pkgImport nixpkgsMaster system false;
      };

      anySystemOutputs = {
        lib = import ./lib { inherit lib; };

        vars = import ./vars;

        overlays = (import ./overlays) // {
          packages = import ./pkgs;
        };
        overlay = self.overlays.packages;

        nixosModules = (import ./modules) // {
          profiles = import ./profiles;
          soxin = import ./soxin/soxin.nix;
          soxincfg = import ./modules/soxincfg.nix;
        };
        nixosModule = self.nixosModules.soxincfg;

        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          import ./hosts (
            recursiveUpdate inputs {
              inherit lib system;
              pkgset = pkgset system;
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
            (removeAttrs self.nixosConfigurations [ "rsn/goat" "rsn/hedgehog" ]);
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };

      multiSystemOutputs = eachDefaultSystem (system:
      let
        inherit (pkgset system) pkgs pkgsUnstable pkgsMaster;
      in
      {
        devShell = pkgs.mkShell {
          name = "soxincfg";

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

        overrides = import ./overlays/overrides.nix { inherit pkgsUnstable pkgsMaster; };

        packages = self.lib.overlaysToPkgs self.overlays pkgs;
      });

    in
    recursiveUpdate multiSystemOutputs anySystemOutputs;
}
