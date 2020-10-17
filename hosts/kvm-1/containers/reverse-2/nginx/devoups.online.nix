{ config, ... }:

{
  services.nginx = {
    upstreams."devoups-1-gratus_8080" = {
      servers = {
        "devoups-1.containers:8080" = {};
      };
    };
    upstreams."devoups-1-gratus_3000" = {
      servers = {
        "devoups-1.containers:3000" = {};
      };
    };
    upstreams."devoups-1-gratus_9090" = {
      servers = {
        "devoups-1.containers:9090" = {};
      };
    };

    virtualHosts."devoups.online" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-devoups.online.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-devoups.online.log;
      '';
      locations."/".proxyPass = "http://devoups-1-gratus_8080";
    };

    virtualHosts."grafana.devoups.online" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-devoups.online.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-devoups.online.log;
      '';
      locations."/".proxyPass = "http://devoups-1-gratus_3000";
    };

    virtualHosts."prometheus.devoups.online" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-devoups.online.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-devoups.online.log;
      '';
      locations."/".proxyPass = "http://devoups-1-gratus_9090";
    };
  };
}
