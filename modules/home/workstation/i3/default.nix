{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shabka.workstation.i3;
in {
  config = mkIf cfg.enable {

    xsession.windowManager.i3 = mkForce (import ./i3-config.lib.nix { inherit config pkgs lib; });

  };
}
