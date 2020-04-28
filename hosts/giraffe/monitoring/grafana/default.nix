{ lib, ... }:

{
  services.grafana = {
    enable = true;
    addr = "172.28.3.1";
    dataDir = "/srv/grafana";
    rootUrl = "http://172.28.3.1:3000";

    provision = {
      enable = true;
      dashboards = [
        {
          folder = "Netdata per-host";
          options.path = "/etc/grafana/dashboards/netdata-per-host";
          disableDeletion = true;
          updateIntervalSeconds = 10;
        }
        {
          folder = "Web";
          options.path = "/etc/grafana/dashboards/web";
          disableDeletion = true;
          updateIntervalSeconds = 10;
        }
      ];
      datasources = [
        {
          name = "InfluxDB";
          type = "influxdb";
          url = "http://localhost:8086";
          isDefault = true;
          editable = false;
          access = "proxy";
          database = "opentsdb_netdata";
        }
      ];
    };
  };

  environment.etc = {
    "grafana/dashboards/netdata-per-host".source = ./dashboards/netdata-per-host;
    "grafana/dashboards/web".source = ./dashboards/web;
  };
}
