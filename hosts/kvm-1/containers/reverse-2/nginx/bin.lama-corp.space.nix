{ config, ... }:

{
  services.nginx = {
    upstreams."bin-lama-corp-space" = {
      servers."web-1.vrt.fsn.lama-corp.space:8006" = {};
    };

    virtualHosts."bin.lama-corp.space" = {
      serverAliases = [
        "bin.risson.space"
        "bin.risson.me"
        "bin.marcerisson.space"
        "bin.risson.tech"
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log ${config.services.nginx.logsDirectory}/access-bin.lama-corp.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-bin.lama-corp.space.log;
      '';
      locations."/".proxyPass = "http://bin-lama-corp-space";
    };
  };
}
