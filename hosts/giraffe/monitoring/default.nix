{ ... }:

{
  imports = [
    ./netdata
    ./influxdb.nix
    ./grafana.nix
  ];
}
