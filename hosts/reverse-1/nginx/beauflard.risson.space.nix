{ ... }:

{
  services.nginx = {
    upstreams."beauflard-risson-space" = {
      servers."web-1.vrt.fsn.lama-corp.space:8001" = {};
    };

    virtualHosts."beauflard.risson.space" = {
      serverAliases = [
        "beauflard.risson.me"
        "beauflard.marcerisson.space"
        "beauflard.risson.tech"
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-beauflard.risson.space.log netdata;
      '';
      locations."/".proxyPass = "http://beauflard-risson-space";
    };
  };
}
