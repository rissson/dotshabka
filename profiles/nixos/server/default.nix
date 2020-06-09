{ ... }:

{
  imports = [
    <dotshabka/roles/common>
    <dotshabka/roles/netdata>
    <dotshabka/roles/ssh>
    <dotshabka/roles/zfs>
    ./root.nix
  ];
}
