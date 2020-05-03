{ ... }:

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
        access_log /var/log/nginx/access-lama-corp.space.log netdata;
      '';
      locations."/".proxyPass = "http://lama-corp-space";
    };
  };
}
