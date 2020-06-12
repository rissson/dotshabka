{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <dotshabka/modules/nixos>

    ./networking.nix

    ./mail
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

    common.backups.startAt = "*-*-* *:04:27 UTC";
  };

  security.dhparams = mkIf config.services.postfix.enable {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    path = "/srv/var/lib/dhparams";
  };

  security.acme =
    mkIf (config.services.postfix.enable || config.services.dovecot.enable) {
      acceptTerms = true;
      email = "caa@lama-corp.space";
    };

  systemd.tmpfiles.rules = [
    "L /var/lib/acme        - - - -   /srv/var/lib/acme"
    "L /var/spool/mail      - - - -   /srv/var/spool/mail"
  ];

  ###
  # Backups
  ###

  services.borgbackup.jobs."system" = {
    paths = [
      "/var/lib/postfix"
      "/var/lib/dovecot"
    ];
  };

  nix.maxJobs = 2;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
