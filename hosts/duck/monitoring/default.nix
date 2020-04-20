{ ... }:

{
  imports = [
    ./netdata
    ./logrotate.nix
    ./smartd.nix
    ./elk
  ];
}
