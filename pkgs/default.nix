channels@{ ... }:

let
  inherit (channels.nixpkgs) callPackage lib system;
  inherit (lib) findSingle filterAttrs platforms;

  pkgs = {
    bird-lg-go-frontend = callPackage ./bird-lg-go/frontend.nix { };
    bird-lg-go-proxy = callPackage ./bird-lg-go/proxy.nix { };

    tmuxp = callPackage ./tmuxp { };
  };

  hasElement = list: elem: (findSingle (x: x == elem) "none" "multiple" list) != "none";
in
filterAttrs (name: pkg: hasElement (pkg.meta.platforms or platforms.all) system) pkgs
