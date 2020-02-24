with import <shabka/util>;

let
  nixos = buildHomeManagerConfiguration { conf = ./configuration.nix; };
in {
  inherit (nixos) system;
}
