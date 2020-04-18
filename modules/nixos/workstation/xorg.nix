{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shabka.workstation.xorg;
in {
  config = mkIf cfg.enable {

    services.xserver.desktopManager.gnome3.enable = mkForce false;
    services.xserver.desktopManager.plasma5.enable = mkForce false;

    services.xserver.xkbOptions = mkForce (concatStringsSep "," [
      "grp:alt_caps_toggle" "caps:swapescape"
    ]);

    services.xserver.libinput.naturalScrolling = mkForce false;

    services.xserver.displayManager.lightdm.autoLogin = mkForce {
      enable = false;
      user = "risson";
    };

  };
}
