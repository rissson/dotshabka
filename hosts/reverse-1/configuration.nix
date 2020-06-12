{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <dotshabka/modules/nixos>

    ./networking.nix
    ./monitoring

    ./nginx
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  lama-corp = {
    profiles = {
      server.enable = true;
      vm = {
        enable = true;
        vmType = "kvm-1";
      };
    };

    common.backups.startAt = "*-*-* *:55:58 UTC";
  };

  nix.maxJobs = 2;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
