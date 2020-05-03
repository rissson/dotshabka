{ ... }:

{
  services.nginx = {
    upstreams."jdmi-risson-space" = {
      servers."web-1.vrt.fsn.lama-corp.space:8002" = {};
    };

    virtualHosts."jdmi.risson.space" = {
      serverAliases =
        [ "jdmi.risson.me" "jdmi.marcerisson.space" "jdmi.risson.tech" ];
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-jdmi.risson.space.log netdata;
      '';
      locations."/".proxyPass = "http://jdmi-risson-space";
    };
  };
}
