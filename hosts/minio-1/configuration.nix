{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking.nix
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

    minio.enable = true;

    common.backups.startAt = "*-*-* *:12:13 UTC";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
