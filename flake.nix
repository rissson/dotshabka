{
  # name = "soxincfg";

  description = "Lama Corp. infrastructure configurations.";

  inputs = {
    nixos.url = "nixpkgs/release-20.03";
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
      inherit (self) lib;
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
            builtInputs = with pkgs; [
              git
              morph
              nixpkgs-fmt
              pre-commit
            ];

            shellHook = ''
              export DOTSHABKA_PATH="$(pwd)"
            '';
          };

          packages = lib.overlaysToPkgs self.overlays osPkgs;
        }
      );

      outputs = {
        lib = nixos.lib.extend (import ./lib);

        vars = import ./vars;

        # TODO
        nixosConfigurations = {};

        # TODO
        nixosModules =
          let
            modulesAttrs = {
              shabka = import ./shabka/nixos/list.nix;
            };
          in
          modulesAttrs;

        overlay = import ./pkgs;

        overlays =
          let
            overlayDir = ./overlays;
            fullPath = name: overlayDir + "/${name}";
            overlayPaths = map fullPath (builtins.attrNames (builtins.readDir overlayDir));
          in
          lib.pathsToImportedAttrs overlayPaths;
      };
    in
    recursiveUpdate multiSystemOutputs outputs;
}
