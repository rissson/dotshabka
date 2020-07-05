{ pkgs, lib, ... }:

with lib;

{
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking
    ./users.nix
    ./backups.nix
    ./monitoring
    ./services
    ./home
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  lama-corp = {
    profiles = {
      primary.enable = true;
    };

    luks.enable = true;
    common.backups.startAt = "*-*-* *:44:30 UTC";
  };

  nix.gc.automatic = mkForce false;

  shabka.virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
