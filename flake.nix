{
  description = "soxincfg";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/release-20.09";
      soxin = {
        url = "git+file:///home/risson/code/soxin";
        inputs = {
          nixpkgs.follows = "nixpkgs";
        };
      };
      impermanence = {
        url = "github:danieldk/impermanence/flake";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixos-hardware.url = "github:NixOS/nixos-hardware";
      nur.url = "github:nix-community/NUR";
    };

  outputs = { self, nixpkgs, soxin, impermanence, nixos-hardware, nur } @ inputs:
    let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [];
        config = { allowUnfree = true; };
      };

      system = "x86_64-linux";
    in
    {
      nixosConfigurations =
        import ./hosts (lib.recursiveUpdate inputs {
          inherit pkgs lib system;
        });

      devShell."${system}" = import ./shell.nix {
        inherit pkgs;
      };

      vars = import ./data { };
    };
}
