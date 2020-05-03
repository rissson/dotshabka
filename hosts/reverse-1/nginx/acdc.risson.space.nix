{ ... }:

{
  services.nginx.upstreams."acdc_risson_space" = {
    servers = {
      "web-1.duck.srv.fsn.lama-corp.space:8000" = {};
    };
  };

  services.nginx.virtualHosts."acdc.risson.space" = {
    serverAliases =
      [ "acdc.risson.me" "acdc.marcerisson.space" "acdc.risson.tech" ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-acdc.risson.space.log netdata;
    '';
    locations."/".proxyPass = "http://acdc_risson_space";
  };
}
