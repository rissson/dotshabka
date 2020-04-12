{ pkgs ? import <nixpkgs> { config = {}; overlays = []; } }:

with pkgs;

{
  path = ./.;
  data = import ./data { };
}
