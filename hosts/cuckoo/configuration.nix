{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>

    <dotshabka/modules/nixos>
    <dotshabka/modules/nixos/server>

    ./hardware-configuration.nix
    ./networking.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  shabka.workstation.sound.enable = true;

  services.spotifyd = {
    enable = true;
    config = ''
      [global]
      backend = alsa
      volume_controller = softvol
      device = front
      control_device = 1
      mixer = PCM
      bitrate = 320

      no_audio_cache = false

      device_name = cuckoo
      device_type = speaker
    '';
  };

  shabka.users = with import <dotshabka/data/users> { }; {
    enable = true;
    users = {
      risson = {
        inherit (risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
      diego = {
        inherit (diego) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/diego";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
