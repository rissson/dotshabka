{ ... }:

{
  services.influxdb = {
    enable = true;
    dataDir = "/srv/influxdb";
  };
}
