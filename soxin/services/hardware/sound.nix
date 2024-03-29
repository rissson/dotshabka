{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.soxin.hardware.sound;
in
{
  options = {
    soxin.hardware.sound = {
      enable = mkEnableOption "Whether to enable sound.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      sound.enable = true;

      hardware = {
        pulseaudio = {
          enable = true;
          package = mkIf config.soxin.hardware.bluetooth.enable pkgs.pulseaudioFull;
          systemWide = true;
        };
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        pa_applet
      ];

      users.groups.pulse-access = {};
    })
  ]);
}
