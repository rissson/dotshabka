{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.services.xserver.windowManager.i3;
in {
  options = {
    lama-corp.services.xserver.windowManager.i3 = {
      enable = mkEnableOption "i3";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      xsession = {
        enable = true;

        windowManager = {
          i3 = import ./i3-config.lib.nix { inherit pkgs lib; };
        };

        initExtra = ''
          exec &> ~/.xsession-errors

          # fix the look of Java applications
          export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
        '';
      };
    })
  ]);
}
