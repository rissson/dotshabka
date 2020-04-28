{ config, lib, pkgs, ... }:

with lib;

{
  services.opendkim = mkIf config.services.postfix.enable {
    enable = true;
    selector = "mail";
    domains = "csl:lama-corp.space,risson.space,risson.me,marcerisson.space,thefractal.space,risson.tech,risson.rocks";
    keyPath = "/srv/mail/dkim";
    configFile = pkgs.writeText "opendkim.conf" ''
      Canonicalization relaxed/simple
      UMask 0002
    '';
  };

  users.users.${config.services.postfix.user}.extraGroups = [ config.services.opendkim.group ];
}
