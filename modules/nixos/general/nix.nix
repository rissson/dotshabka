{ config, pkgs, lib, ... }:

{
  nix = {
    binaryCaches = [
      "https://risson.cachix.org"
    ];
  };
}
