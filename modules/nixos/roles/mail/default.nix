{ config, lib, ... }:

with lib;

/* TODO

   Look into postsrsd, see if it affects sending with one of a user's aliases
   */
let
  cfg = config.lama-corp.mail;
in {

  options = {
    lama-corp.mail.enable = mkEnableOption "Enable mail settings";
  };

  config = mkIf cfg.enable {
    imports =
      [ ./clamav.nix ./dovecot.nix ./postfix.nix ./opendkim.nix ./rspamd.nix ];
  };
}
