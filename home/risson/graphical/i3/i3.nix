{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.lama-corp.graphical {
    xsession.windowManager.i3 = mkForce (import ./i3-config.lib.nix { inherit config pkgs lib; });
  };
}
