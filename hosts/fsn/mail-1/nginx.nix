{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.dhparams = {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    params."nginx".bits = 2048;
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
    commonHttpConfig = ''
      log_format netdata '$host:$server_port $remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '$request_length $request_time $upstream_response_time';
      access_log /var/log/nginx/access.log netdata;
    '';
    logError = "/var/log/nginx/error.log";

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslDhparam = config.security.dhparams.params."nginx".path;
  };
}
