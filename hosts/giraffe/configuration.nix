{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking
    ./monitoring

  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  lama-corp = {
    profiles = {
      primary.enable = true;
      vm = {
        enable = true;
        vmType = "hetzner";
      };
    };

    common.backups.startAt = "*-*-* *:33:53 UTC";
    luks.enable = true;
    unbound.enable = mkForce false;
  };

  # No users needed as we have a console access to this host
  shabka.users.enable = mkForce false;

  services.zfs.autoSnapshot.enable = mkForce false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
