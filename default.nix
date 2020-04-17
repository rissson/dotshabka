{ pkgs ? import <nixpkgs> { config = {}; overlays = []; } }:

with pkgs;

{
  path = ./.;
  data = import ./data { };
  external = import ./external { inherit stdenNoCC; };
}
