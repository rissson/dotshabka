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

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/fping.conf".text = ''
      fping="${pkgs.fping}/bin/fping"
      hosts="duck.srv.fsn.lama-corp.space hub.virt.duck.srv.fsn.lama-corp.space nas.srv.bar.lama-corp.space"
    '';
  };
}
