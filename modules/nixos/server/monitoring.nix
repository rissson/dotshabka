{ config, lib, pkgs, ... }:

with lib;

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};
in {
  nixpkgs.overlays = [
    (self: super: {
      netdata = nixpkgs.netdata;
    })
  ];

  services.netdata.enable = true;
}
