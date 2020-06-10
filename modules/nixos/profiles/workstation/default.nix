{ lib, ... }:

with import <shabka/util>;

{
  imports = recImport ./.;

  shabka.printing.enable = true;

  shabka.workstation = {
    autorandr.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    gtk.enable = true;
    power.enable = true;
    sound.enable = true;
    virtualbox.enable = lib.mkForce false;
    xorg.enable = true;
  };
}
