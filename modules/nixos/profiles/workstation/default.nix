{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.workstation;
in {
  options = {
    lama-corp.profiles.workstation = {
      enable = mkEnableOption "Enable profile for workstation hosts";
      primaryUser = mkOption {
        type = types.str;
        default = "";
        description = "Primary user of the workstation";
      };
      isLaptop = mkEnableOption "Whether the workstation is a laptop";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      lama-corp.common.enable = true;

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

      services.xserver.videoDrivers = [ "radeon" "cirrus" "vesa" "vmware" "modesetting" "intel" ];

      services.xserver.displayManager.lightdm.autoLogin = mkForce {
        enable = true;
        user = cfg.primaryUser;
      };
    }

    (optionalAttrs cfg.isLaptop {
      services.logind = {
        lidSwitch = "hybrid-sleep";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "hybrid-sleep";
        extraConfig = ''
          HandlePowerKey=suspend
        '';
      };
    })

    (optionalAttrs (cfg.primaryUser == "risson") {
      services.xserver.xkbOptions = mkForce (concatStringsSep "," [
        "grp:alt_caps_toggle" "caps:swapescape"
      ]);

      services.xserver.libinput.naturalScrolling = mkForce false;
    })
  ]);
}
