channels@{ ... }:

let
  inherit (channels) nixpkgs;
  inherit (nixpkgs) callPackage lib system;
  inherit (lib) findSingle filterAttrs platforms;

  pkgs = {
    bird-lg-go-frontend = callPackage ./bird-lg-go/frontend.nix { };
    bird-lg-go-proxy = callPackage ./bird-lg-go/proxy.nix { };

    nix-docker = nixpkgs.docker-nixpkgs.nix.override {
      nix = nixpkgs.nixFlakes;
      extraContents = [
        nixpkgs.findutils
        (nixpkgs.writeTextFile {
          name = "nix.conf";
          destination = "/etc/nix/nix.conf";
          text = ''
            experimental-features = nix-command flakes ca-references
            substituters = http://cache.nixos.org http://s3.lama-corp.space/cache.nix.lama-corp.space http://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr
            trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nix.lama-corp.space:zXDtep4OcIi2/hkqNmA1UkAoDTGBZE/YvEQdT750L1M= cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=
          '';
        })
      ];
    };
  };

  hasElement = list: elem: (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
filterAttrs (name: pkg: hasElement (pkg.meta.platforms or platforms.all) system) pkgs
