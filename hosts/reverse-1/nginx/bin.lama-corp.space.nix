{ ... }:

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
        access_log /var/log/nginx/access-bin.lama-corp.space.log netdata;
      '';
      locations."/".proxyPass = "http://bin-lama-corp-space";
    };
  };
}
