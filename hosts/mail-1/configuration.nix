{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/nixos>
    <dotshabka/modules/nixos>
    <dotshabka/modules/nixos/server>

    ./hardware-configuration.nix
    ./networking.nix
    ./backups.nix
    ./monitoring

    ./mail
  ]
  ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets") (singleton "${<dotshabka>}/secrets"));

  security.dhparams = mkIf config.services.postfix.enable {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    path = "/srv/var/lib/dhparams";
  };

  security.acme = mkIf (config.services.postfix.enable || config.services.dovecot.enable) {
    acceptTerms = true;
    email = "caa@lama-corp.space";
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/acme        - - - -   /srv/var/lib/acme"
    "L /var/spool/mail      - - - -   /srv/var/spool/mail"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
