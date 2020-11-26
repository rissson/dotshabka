{ config, pkgs, ... }:

{
  services.opendkim = {
    enable = true;
    selector = "mail";
    domains = "csl:lama-corp.space,risson.space,risson.me,marcerisson.space,thefractal.space,risson.tech,risson.rocks,lewdax.space";
    configFile = pkgs.writeText "opendkim.conf" ''
      Canonicalization relaxed/simple
      UMask 0002
      RequireSafeKeys false
    '';
  };

  systemd.services.postfix = {
    after = [ "opendkim.service" ];
    requires = [ "opendkim.service" ];
  };

  users.users.${config.services.postfix.user}.extraGroups = [ config.services.opendkim.group ];
}
