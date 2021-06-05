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

    deploy-rs.url = "github:serokell/deploy-rs";
    dns.url = "github:kirelagin/dns.nix";
    flakeUtilsPlus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.1.0";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "nixos-hardware";
    nur.url = "nur";
    sops-nix.url = "github:Mic92/sops-nix";

    soxin = {
      url = "github:SoxinOS/soxin";
      inputs = {
        deploy-rs.follows = "deploy-rs";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        sops-nix.follows = "sops-nix";
        unstable.follows = "nixpkgsUnstable";
        utils.follows = "flakeUtilsPlus";
      };
    };
  };

  outputs =
    { self
    , nixpkgs, nixpkgsUnstable, nixpkgsMaster, home-manager
    , deploy-rs, dns, flakeUtilsPlus, impermanence, nixos-hardware, nur, sops-nix
    , soxin
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) attrValues;
      inherit (flakeUtilsPlus.lib) flattenTree;

      withDeploy = true; # enable deploy-rs support
      withSops = true; # enable sops-nix support
    in
    soxin.lib.systemFlake {
      inherit withDeploy withSops;
      inherit inputs;

      # TODO: registry
      # channel definitions. `channels.<name>.{input,overlaysBuilder,config,patches}`
      channels = {
        # TODO: all three nixpkgs
        nixpkgs = {
          # TODO: overlays
          # channel specific configuration. Overwrites `channelsConfig`
          # argument
          config = { };
          # Patches to apply to nixpkgs
          patches = [ ];
        };
      };
      sharedOverlays = (attrValues self.overlays);

      # default configuration values for `channels.<name>.config = {...}`
      channelsConfig = {
        # allowBroken = true;
        allowUnfree = true;
        # allowUnsupportedSystem = true;
      };

      nixosModules = (import ./modules) // {
        profiles = import ./profiles; # common configuration for multiple hosts
        soxin = import ./soxin/soxin.nix; # TODO: let's get rid of it
        soxincfg = import ./modules/soxincfg.nix; # all modules, except profiles
      };
      nixosModule = self.nixosModules.soxincfg;

      # modules added to all builders
      extraGlobalModules = [
        self.nixosModule
        self.nixosModules.soxin
      ];
      # modules added to NixOS builders
      extraNixosModules = [
        impermanence.nixosModules.impermanence
      ];

      # supported systems, used for packages, apps, devShell and multiple other
      # definitions. Defaults to `flake-utils.lib.defaultSystems`
      supportedSystems = flakeUtilsPlus.lib.defaultSystems;

      # pull in all hosts
      hosts = import ./hosts ({ inherit lib; } // inputs);

      # pull in all home-manager's configurations
      home-managers = import ./home-manager inputs;

      # evaluates to `packages.<system>.<pname> =
      # <unstable-channel-reference>.<pname>`
      packagesBuilder = channels: flattenTree (import ./pkgs channels);

      vars = import ./vars (inputs // { inherit withSops; });

      # include all overlays
      overlays = import ./overlays;

      globalSpecialArgs = {
        userName = "risson"; # TODO: do this another way
      };
      # set the NixOS specialArgs
      nixosSpecialArgs = {
        inherit nixpkgsUnstable nixpkgsMaster;
        inherit dns nixos-hardware;
      };
    };












    /*let
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
    recursiveUpdate multiSystemOutputs anySystemOutputs;*/
}
