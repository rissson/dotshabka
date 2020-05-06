{ ... }:

{
  services.nginx = {
    upstreams."tp14-acdc-risson-space" = {
      servers."acdc-tp14-1.vrt.fsn.lama-corp.space:3000" = {};
    };

    upstreams."api-tp14-acdc-risson-space" = {
      servers."acdc-tp14-1.vrt.fsn.lama-corp.space:3456" = {};
    };

    virtualHosts."tp14.acdc.risson.space" = {
      serverAliases = [
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-tp14.acdc.risson.space.log netdata;
      '';
      locations."/".proxyPass = "http://tp14-acdc-risson-space";
    };

    virtualHosts."api.tp14.acdc.risson.space" = {
      serverAliases = [
      ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-api.tp14.acdc.risson.space.log netdata;
      '';
      locations."/".proxyPass = "http://api-tp14-acdc-risson-space";
    };
  };
}
