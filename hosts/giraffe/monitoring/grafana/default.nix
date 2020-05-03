{ config, lib, ... }:

with lib;

{
  services.grafana = {
    enable = true;
    addr = "172.28.3.1";
    dataDir = "/srv/grafana";
    rootUrl = "https://grafana.lama-corp.space/";
    domain = "grafana.lama-corp.space";

    auth.anonymous.enable = true;

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
      datasources = [{
        name = "InfluxDB";
        type = "influxdb";
        url = "http://localhost:8086";
        isDefault = true;
        editable = false;
        access = "proxy";
        database = "opentsdb_netdata";
      }];
    };
  };

  environment.etc = mkIf config.services.grafana.enable {
    "grafana/dashboards/netdata-per-host".source =
      ./dashboards/netdata-per-host;
    "grafana/dashboards/web".source = ./dashboards/web;
  };
}
