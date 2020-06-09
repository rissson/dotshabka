{ ... }:

{
  services.influxdb = {
    enable = true;
    dataDir = "/srv/influxdb";
    extraConfig = {
      opentsdb = [{
        enabled = true;
        bind-address = ":${toString port}";
        database = "opentsdb_netdata";
      }];
    };
  };
}
