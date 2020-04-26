{ ... }:

/*
TODO

Look into postsrsd, see if it affects sending with one of a user's aliases
*/
{
  imports = [
    ./dovecot.nix
    ./postfix.nix
    ./rspamd.nix
  ];
}
