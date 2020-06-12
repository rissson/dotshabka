{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <dotshabka/modules/nixos>

    ./networking.nix
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

    postgresql = {
      enable = true;
      ensureDatabasesAndUsers = [ "catcdc" "codimd" "pastebin" "scoreboard_seedbox_cri" ];
    };

    common.backups.startAt = "*-*-* *:00:06 UTC";
  };

  nix.maxJobs = 1;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
