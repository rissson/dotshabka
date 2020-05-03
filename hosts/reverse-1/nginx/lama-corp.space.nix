{ ... }:

{
  services.nginx.virtualHosts."lama-corp.space" = {
    serverAliases = [ "www.lama-corp.space" ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-lama-corp.space.log netdata;
    '';
    locations."/".proxyPass = "http://web-1.duck.srv.fsn.lama-corp.space:8003";
  };
}
