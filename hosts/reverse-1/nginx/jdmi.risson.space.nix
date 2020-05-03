{ ... }:

{
  services.nginx.virtualHosts."jdmi.risson.space" = {
    serverAliases =
      [ "jdmi.risson.me" "jdmi.marcerisson.space" "jdmi.risson.tech" ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-jdmi.risson.space.log netdata;
    '';
    locations."/".proxyPass = "http://web-1.duck.srv.fsn.lama-corp.space:8002";
  };
}
