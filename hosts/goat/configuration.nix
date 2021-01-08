{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation

    ./hardware-configuration.nix
    ./networking.nix
  ];

  nix.gc.automatic = lib.mkForce false;
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  #### TESTING

  services.nginx = {
    enable = true;
    virtualHosts = {
      "lama-corp.cri.epita.net" = {
        extraConfig = ''
          # Redirect the user to the login page when they are not logged in
          error_page 401 = @error401;
        '';
        locations = {
          "/" = {
            root = "/home/risson/lama-corp";
            extraConfig = ''
              autoindex on;

              # Protect this location using the auth_request
              auth_request /auth_request;

              # Automatically renew SSO cookie on request
              auth_request_set $cookie $upstream_http_set_cookie;
              add_header Set-Cookie $cookie;
            '';
          };
          "/infra" = {
            root = "/home/risson/lama-corp";
            extraConfig = ''
              autoindex on;
            '';
          };
          "= /auth_request" = {
            proxyPass = "http://cri.epita.net:8000/auth/request/";
            extraConfig = ''
              # Do not allow requests from outside
              #internal;

              # Do not forward the request body (the intranet does not care about it)
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";

              # Set custom information for ACL matching
              proxy_set_header X-Origin-Scheme $scheme;
              proxy_set_header X-Origin-Host "lama-corp.cri.epita.net";
              proxy_set_header X-Origin-URI $request_uri;

              # Standard proxy information
              proxy_set_header Host cri.epita.net;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;
              proxy_set_header Accept-Encoding "";
            '';
          };
          "@error401" = {
            extraConfig = ''
              # Automatically renew SSO cookie on request
              auth_request_set $cookie $upstream_http_set_cookie;
              add_header Set-Cookie $cookie;

              return 307 http://cri.epita.net:8000/auth/login/;
            '';
          };
        };
      };
    };
  };

  networking.extraHosts = ''
    127.0.0.1 cri.epita.net
    127.0.0.1 lama-corp.cri.epita.net
    127.0.0.1 code.cri.epita.net
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
