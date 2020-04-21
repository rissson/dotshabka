{ ... }:

{
  imports = [
    ./netdata
    ./logrotate.nix
    ./smartd.nix
    ./elk.nix
    ./influxdb.nix
  ];
}
