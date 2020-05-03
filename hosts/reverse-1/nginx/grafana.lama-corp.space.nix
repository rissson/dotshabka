{ ... }:

{
  services.nginx.virtualHosts."grafana.lama-corp.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-grafana.lama-corp.space.log netdata;
    '';
    locations."/".proxyPass = "http://giraffe.srv.nbg.lama-corp.space:3000";
  };
}
