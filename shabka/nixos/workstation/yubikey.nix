{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yubico-piv-tool
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    yubioath-desktop
  ];

  services.pcscd.enable = true;

  security.pam.u2f = {
    enable = true;
    cue = true;
  };
}
