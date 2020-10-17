{ config, ... }:

{
  services.nginx = {
    upstreams."cloud-lama-corp-space" = {
      servers."nextcloud-1.containers:80" = {};
    };

    virtualHosts."cloud.lama-corp.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-cloud.lama-corp.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-cloud.lama-corp.space.log;
      '';
      locations."/".proxyPass = "http://cloud-lama-corp-space";
    };
  };
}
