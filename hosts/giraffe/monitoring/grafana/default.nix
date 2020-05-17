{ config, pkgs, lib, ... }:

with lib;

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    dataDir = "/srv/postgresql/11";
    ensureDatabases = [ "grafana" ];
    ensureUsers = [
      {
        name = "grafana";
        ensurePermissions = { "DATABASE grafana" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/srv/backups";
    startAt = "*-*-* 18:47:52 UTC";
  };

  services.grafana = {
    enable = true;
    addr = "172.28.3.1";
    dataDir = "/srv/grafana";
    rootUrl = "https://grafana.lama-corp.space/";
    domain = "grafana.lama-corp.space";

    database = {
      type = "postgres";
      host = "localhost:5432";
      name = "grafana";
      user = "grafana";
      passwordFile = "/srv/secrets/grafana/database.passwd";
    };

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
