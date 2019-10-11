{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

in {
  imports = [
    ./hardware-configuration.nix

    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"

    <shabka/modules/nixos>
    ../../modules/nixos

    ./home.nix
  ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  networking.hostName = "hedgehog";

  shabka.hardware.intel_backlight.enable = true;
  shabka.printing.enable = true;
  shabka.users.enable = true;
  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.keyboard.layouts = [ "bepo" "qwerty_intl" ];
  shabka.keyboard.enableAtBoot = false;

  shabka.workstation = {
    autorandr.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    networking.enable = true;
    power.enable = true;
    sound.enable = true;
    teamviewer.enable = true;
    #virtualbox.enable = true;
    xorg.enable = true;
  };

  shabka.hardware.machine = "thinkpad-e580";

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
