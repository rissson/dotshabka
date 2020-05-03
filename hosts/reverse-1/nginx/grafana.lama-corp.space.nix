{ ... }:

{
  services.nginx = {
    upstreams."grafana-lama-corp-space" = {
      servers."giraffe.srv.nbg.lama-corp.space:3000" = {};
    };

    virtualHosts."grafana.lama-corp.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-grafana.lama-corp.space.log netdata;
      '';
      locations."/".proxyPass = "http://grafana-lama-corp-space";
    };
  };
}
