{ config, lib, ... }:

with lib;

/* TODO

Look into postsrsd, see if it affects sending with one of a user's aliases
*/
{
  imports =
    [ ./clamav.nix ./dovecot.nix ./postfix.nix ./opendkim.nix ./rspamd.nix ];
}
