{ config, ... }:

{
  services.nginx = {
    upstreams."jdmi-risson-space" = {
      servers."jdmi-1.containers:80" = {};
    };

    virtualHosts."jdmi.risson.space" = {
      serverAliases =
        [ "jdmi.risson.me" "jdmi.marcerisson.space" "jdmi.risson.tech" ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-jdmi.risson.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-jdmi.risson.space.log;
      '';
      locations."/".proxyPass = "http://jdmi-risson-space";
    };
  };
}
