{ config, pkgs, lib, ... }:
{
  #TODO: https://support.cloudflare.com/hc/en-us/articles/204899617 /srv/certs/cloudflare.pem
  imports = [
    ./web/beauflard.nix
    ./web/jdmi.nix
    ./web/lama-corp.space.nix
    ./web/risson.space.nix
    ./web/upload.nix
  ];

  security.dhparams = {
    enable = true;
    defaultBitSize = 4096;
    stateful = false;
    params."nginx".bits = 4096;
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;

    # Same limit as Cloudflare
    clientMaxBodySize = "100m";

    # Logging settings
    commonHttpConfig = ''
      log_format default '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '$request_length $request_time '
                         '"$http_referer" "$http_user_agent"';
      access_log /var/log/nginx/access.log default;
    '';

    # Because yes.
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Security settings
    sslDhparam = config.security.dhparams.params."nginx".path;
  };

  security.acme.production = true;
}
