{ config, pkgs, lib, ... }:

with lib;

let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <dotshabka/modules/nixos>
    "${impermanence}/nixos.nix"

    ./networking.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  environment.persistence."/srv" = {
    directories = [
      "/var/lib/kubernetes"
      "/var/lib/docker"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
  fileSystems."/srv".neededForBoot = true;

  lama-corp = {
    profiles = {
      server.enable = true;
      vm = {
        enable = true;
        vmType = "kvm-1";
      };
    };

    common.backups.startAt = "*-*-* *:04:27 UTC";
  };

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "k8s-master-11.vrt.fsn.lama-corp.space";
    easyCerts = true;
  };

  nix.maxJobs = 2;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
