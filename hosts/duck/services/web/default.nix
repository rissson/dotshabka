{ config, pkgs, lib, ... }: {
  disabledModules = [ "services/web-servers/uwsgi.nix" ];

  # TODO: score an A+ at SSLlabs
  imports = [
    ./acdc.nix
    ./beauflard.nix
    ./cats.acdc.risson.space.nix
    ./codimd.nix
    ./jdmi.nix
    ./lama-corp.space.nix
    ./pastebin.nix
    ./risson.space.nix
    ./scoreboard-seedbox-cri.nix
    ./thefractal.space.nix
    ./upload.nix
    ./uwsgi.nix
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
    group = "deploy";

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

  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance = { type = "emperor"; };
    group = "deploy";
  };

  security.acme = {
    acceptTerms = true;
    email = "caa@lama-corp.space";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
