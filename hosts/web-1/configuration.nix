{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking.nix

    ./web
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  lama-corp = {
    profiles = {
      server.enable = true;
      vm = {
        enable = true;
        type = "kvm-1";
      };
    };

    common.backups.startAt = "*-*-* *:58:23 UTC";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
