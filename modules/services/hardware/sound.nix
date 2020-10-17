{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.hardware.sound;
in
{
  options = {
    lama-corp.hardware.sound = {
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
        };
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        pa_applet
      ];
    })
  ]);
}
