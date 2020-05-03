{ ... }:

{
  services.nginx.upstreams."md-lama-corp-space" = {
    servers."web-1.vrt.fsn.lama-corp.space:8007" = {};
  };

  services.nginx.virtualHosts."md.lama-corp.space" = {
    serverAliases = [
      "md.risson.space"
      "md.marcerisson.space"
      "md.risson.me"
      "md.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-md.lama-corp.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://md-lama-corp-space";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
