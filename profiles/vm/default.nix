{ ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ../server ../backups ];
}
