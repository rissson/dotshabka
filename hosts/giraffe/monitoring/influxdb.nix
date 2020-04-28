{ ... }:

{
  services.influxdb = {
    enable = true;
    dataDir = "/srv/influxdb";
    extraConfig = {
      opentsdb = [{
        enabled = true;
        bind-address = ":20042";
        database = "opentsdb_netdata";
      }];
    };
  };
}
