{ config, pkgs, lib, ... }:

with lib;

let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
  # TODO: score an A+ at SSLlabs
  imports = [
    "${impermanence}/nixos.nix"

    ./haproxy.nix

    ./nginx/acdc.risson.space.nix
    ./nginx/bin.lama-corp.space.nix
    ./nginx/cats.acdc.risson.space.nix
    ./nginx/chat.lama-corp.space.nix
    ./nginx/cloud.lama-corp.space.nix
    ./nginx/devoups.online.nix
    ./nginx/grafana.lama-corp.space.nix
    ./nginx/jdmi.risson.space.nix
    ./nginx/lama-corp.space.nix
    ./nginx/md.lama-corp.space.nix
    ./nginx/netdata.lama-corp.space.nix
    ./nginx/risson.space.nix
    ./nginx/scoreboard-seedbox-cri.risson.space.nix
    ./nginx/static.lama-corp.space.nix
    ./nginx/thefractal.space.nix
  ];

  options.services.nginx.logsDirectory = mkOption {
    default = "/var/log/nginx";
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 443 25505 ];

    environment.persistence."/persist" = {
      directories = [
        config.security.dhparams.path
        "/var/lib/acme"
        config.services.nginx.logsDirectory
      ];
    };

    security.dhparams = mkIf config.services.nginx.enable {
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
          access_log ${config.services.nginx.logsDirectory}/access.log netdata;
      '';
      logError = "${config.services.nginx.logsDirectory}/error.log";

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      sslDhparam = config.security.dhparams.params."nginx".path;

      appendHttpConfig = ''
          server {
          listen 80;
          ${optionalString config.networking.enableIPv6 "listen [::]:80;" }
          server_name localhost;
          location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 172.28.0.0/16;
            ${optionalString config.networking.enableIPv6 "allow ::1;"}
            deny all;
          }
          }
      '';
    };

    security.acme = mkIf config.services.nginx.enable {
      acceptTerms = true;
      email = "caa@lama-corp.space";
      #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };

    services.logrotate = {
      enable = true;
      config = ''
        ${config.services.nginx.logsDirectory}/* {
        weekly
        missingok
        rotate ${toString (52 * 5)}
        compress
        delaycompress
        notifempty
        create 644 nginx nginx
        olddir ${config.services.nginx.logsDirectory}/rotated
        sharedscripts
        postrotate
          [ ! -f /run/nginx/nginx.pid ] || kill -USR1 $(cat /run/nginx/nginx.pid)
        endscript
        }
      '';
    };
  };
}
