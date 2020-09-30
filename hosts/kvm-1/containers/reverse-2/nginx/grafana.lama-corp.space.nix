{ config, ... }:

{
  services.nginx = {
    upstreams."grafana-lama-corp-space" = {
      servers."giraffe.srv.nbg.lama-corp.space:3000" = {};
    };

    virtualHosts."grafana.lama-corp.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-grafana.lama-corp.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-grafana.lama-corp.space.log;
      '';
      locations."/".proxyPass = "http://grafana-lama-corp-space";
    };
  };
}
