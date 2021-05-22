{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.dhparams = {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    params."nginx".bits = 2048;
  };

  security.acme = {
    acceptTerms = true;
    email = "caa@lama-corp.space";
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

    virtualHosts."vault.lama-corp.space" = {
      listen = [
        { addr = "168.119.71.47"; port = 80; }
        { addr = "168.119.71.47"; port = 443; ssl = true; }
        { addr = "172.28.254.6"; port = 80; }
        { addr = "172.28.254.6"; port = 443; ssl = true; }
        { addr = "172.28.6.254"; port = 80; }
        { addr = "172.28.6.254"; port = 443; ssl = true; }
      ];
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:8200";
    };

    virtualHosts."lg.lama.tel" = {
      listen = [
        { addr = "168.119.71.47"; port = 80; }
        { addr = "168.119.71.47"; port = 443; ssl = true; }
        { addr = "172.28.254.6"; port = 80; }
        { addr = "172.28.254.6"; port = 443; ssl = true; }
        { addr = "172.28.6.254"; port = 80; }
        { addr = "172.28.6.254"; port = 443; ssl = true; }
      ];
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:5000";
    };

    virtualHosts."netdata.lama-corp.space" = {
      listen = [
        { addr = "168.119.71.47"; port = 80; }
        { addr = "168.119.71.47"; port = 443; ssl = true; }
        { addr = "172.28.254.6"; port = 80; }
        { addr = "172.28.254.6"; port = 443; ssl = true; }
        { addr = "172.28.6.254"; port = 80; }
        { addr = "172.28.6.254"; port = 443; ssl = true; }
      ];
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:19999";
      locations."~ /(netdata|host)/(?<behost>[^/\\s]+)/(?<ndpath>.*)" = {
        proxyPass = "http://$behost:19999/$ndpath$is_args$args";
      };
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      gixy = prev.pkgs.stdenv.mkDerivation {
        name = "gixy-wrapped";
        buildInputs = [ prev.makeWrapper prev.gixy ];

        phases = [ "installPhase" ];

        installPhase = ''
          mkdir -p $out/bin
          makeWrapper ${prev.gixy}/bin/gixy $out/bin/gixy \
            --add-flags "--skips ssrf"
        '';
      };
    })
  ];
}
