{ ... }:

{
  services.nginx.virtualHosts."grafana.lama-corp.space" = {
    serverAliases = [
      "grafana.risson.space"
      "grafana.risson.me"
      "grafana.marcerisson.space"
      "grafana.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-chat.lama-corp.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://giraffe.srv.nbg.lama-corp.space:3000";
      };
    };
  };
}
