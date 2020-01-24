with import <shabka/util>;

let
  nixos = buildHomeManagerConfiguration { conf = ./home.nix; };
in {
  inherit (nixos) system;
}
