{ config, ... }:

{
  services.nginx = {
    upstreams."risson-space" = {
      servers."web-1.vrt.fsn.lama-corp.space:8004" = {};
    };

    virtualHosts."risson.space" = {
      serverAliases = [
        "risson.lama-corp.space"
        "www.risson.space"
        "risson.me"
        "www.risson.me"
        "marcerisson.space"
        "www.marcerisson.space"
        "risson.tech"
        "www.risson.tech"
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-risson.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-risson.space.log;
      '';
      locations."/".proxyPass = "http://risson-space";
    };
  };
}
