{ ... }:

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
        access_log /var/log/nginx/access-risson.space.log netdata;
      '';
      locations."/".proxyPass = "http://risson-space";
    };
  };
}
