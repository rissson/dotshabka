{ config, pkgs, lib, ... }:

{
  # TODO: score an A+ at SSLlabs
  imports = [
    ./acdc.risson.space.nix
    ./beauflard.risson.space.nix
    ./cats.acdc.risson.space.nix
    ./grafana.lama-corp.space.nix
    ./jdmi.risson.space.nix
    ./lama-corp.space.nix
    ./netdata.lama-corp.space.nix
    ./risson.space.nix
  ];

  security.dhparams = {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    params."nginx".bits = 2048;
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;

    clientMaxBodySize = "100m";

    commonHttpConfig = ''
      log_format netdata '$host:$server_port $remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '$request_length $request_time $upstream_response_time';
      access_log /var/log/nginx/access.log netdata;
    '';

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    sslDhparam = config.security.dhparams.params."nginx".path;

    statusPage = true;
  };

  security.acme = {
    acceptTerms = true;
    email = "caa@lama-corp.space";
    #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  };

  systemd.tmpfiles.rules =
    [ "L /var/lib/acme        - - - -   /srv/var/lib/acme" ];
}
