{ ... }:

{
  imports = [
    <dotshabka/roles/nixos/common>
    <dotshabka/roles/nixos/netdata>
    <dotshabka/roles/nixos/ssh>
    <dotshabka/roles/nixos/zfs>
    ./root.nix
    ./power.nix
  ];
}
