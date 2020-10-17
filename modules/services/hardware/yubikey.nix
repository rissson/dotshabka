{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.hardware.yubikey;
in
{
  options = {
    lama-corp.hardware.yubikey = {
      enable = mkEnableOption "Whether to enable Yubikey.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      environment.systemPackages = with pkgs; [
        yubico-piv-tool
        yubikey-manager
        yubikey-personalization
        yubikey-personalization-gui
        yubioath-desktop
      ];

      services.pcscd.enable = true;

      # TODO: option
      security.pam.u2f = {
        enable = true;
        cue = true;
      };
    })
  ]);
}
