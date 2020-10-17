{ config, ... }:

{
  services.nginx = {
    upstreams."acdc-risson-space" = {
      servers = {
        "acdc-1.containers:80" = {};
      };
    };

    virtualHosts."acdc.risson.space" = {
      serverAliases =
        [ "acdc.risson.me" "acdc.marcerisson.space" "acdc.risson.tech" ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-acdc.risson.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-acdc.risson.space.log;
      '';
      locations."/".proxyPass = "http://acdc-risson-space";
    };
  };
}
