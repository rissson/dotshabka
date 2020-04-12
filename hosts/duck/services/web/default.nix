{ config, pkgs, lib, ... }:
{
  # TODO: score an A+ at SSLlabs
  # TODO: register email for ACME
  imports = [
    ./acdc.nix
    ./beauflard.nix
    ./cAtCDC.nix
    ./codimd.nix
    ./jdmi.nix
    ./lama-corp.space.nix
    ./pastebin.nix
    ./risson.space.nix
    ./scoreboard-seedbox-cri.nix
    ./upload.nix
  ];

  security.dhparams = {
    enable = true;
    defaultBitSize = 2048;
    stateful = false;
    params."nginx".bits = 2048;
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
    group = "deploy";

    clientMaxBodySize = "100m";

    # Logging settings
    # TODO: more fine logging and integration with netdata
    commonHttpConfig = ''
      log_format default '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '$request_length $request_time '
                         '"$http_referer" "$http_user_agent"';
      access_log /var/log/nginx/access.log default;
    '';

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslDhparam = config.security.dhparams.params."nginx".path;
  };

  security.acme.production = true;
}
