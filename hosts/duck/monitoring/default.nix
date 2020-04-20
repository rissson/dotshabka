{ ... }:

{
  imports = [
    ./netdata
    ./logrotate.nix
    ./smartd.nix
    ./influxdb.nix
    ./grafana.nix
  ];
}
