{ config, ... }:

{
  services.nginx = {
    upstreams."static-lama-corp-space" = {
      servers."minio-1.vrt.fsn.lama-corp.space:19000" = {};
    };

    virtualHosts."static.lama-corp.space" = {
      serverAliases = [
        "static.risson.space"
        "static.risson.me"
        "static.marcerisson.space"
        "static.risson.tech"
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        # They will get denied by Minio if the credentials are wrong anyway
        # We only give credentials to people we trust
        client_max_body_size 0;
        access_log ${config.services.nginx.logsDirectory}/access-static.lama-corp.space.log netdata;
        error_log ${config.services.nginx.logsDirectory}/error-static.lama-corp.space.log;
      '';
      locations."/" = {
        proxyPass = "http://static-lama-corp-space";
        extraConfig = ''
          proxy_redirect off;
        '';
      };
    };
  };
}
