{ config, ... }:

{
  services.nginx = {
    upstreams."lama-corp-space" = {
      servers."web-1.vrt.fsn.lama-corp.space:8003" = {};
    };

    virtualHosts."lama-corp.space" = {
      serverAliases = [ "www.lama-corp.space" ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-lama-corp.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-lama-corp.space.log;
      '';
      locations."/".proxyPass = "http://lama-corp-space";
    };
  };
}
