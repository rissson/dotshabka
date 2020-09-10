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

  config = mkIf cfg.enable {
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

    services.xserver = {
      videoDrivers = [ "radeon" "cirrus" "vesa" "vmware" "modesetting" "intel" ];

      displayManager.lightdm.autoLogin = mkForce {
        enable = true;
        user = cfg.primaryUser;
      };

      xkbOptions = mkForce (concatStringsSep "," (flatten [
        (optionals (cfg.primaryUser == "risson") [ "grp:alt_caps_toggle" "caps:swapescape" ])
        (optionals (cfg.primaryUser == "diego") [ "grp:alt_caps_toggle" ])
      ]));

      libinput.naturalScrolling = mkForce false;
    };

    services.logind = mkIf cfg.isLaptop {
      lidSwitch = "hybrid-sleep";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "hybrid-sleep";
      extraConfig = ''
          HandlePowerKey=suspend
      '';
    };
  };
}
