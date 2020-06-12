{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking.nix
    ./backups.nix
    ./monitoring
    ./dyndns.nix

    ./dns.nix
    ./dhcp.nix

    ./home
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  lama-corp = {
    profiles = {
      primary.enable = true;
    };

    common.backups.enable = mkForce false;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
