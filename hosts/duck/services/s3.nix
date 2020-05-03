{ ... }:

{
  services.minio = {
    enable = false; # Enabled by secrets
    listenAddress = "172.28.1.1:19000";
    configDir = "/srv/minio/config";
    dataDir = "/srv/minio/data";
  };

  security.acme.certs."static.lama-corp.space".email = "caa@lama-corp.space";
  services.nginx.virtualHosts."static.lama-corp.space" = {
    serverAliases = [
      "static.risson.space"
      "static.risson.me"
      "static.marcerisson.space"
      "static.risson.tech"
      "static.cats.acdc.epita.fr"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      # They will get denied by Minio if the credentials are wrong anyway
      # We only give credentials to people we trust
      client_max_body_size 0;
      access_log /var/log/nginx/access-static.lama-corp.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://172.28.1.1:19000";
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
