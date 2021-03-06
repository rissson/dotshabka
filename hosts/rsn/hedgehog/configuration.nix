{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation

    ./hardware-configuration.nix
    ./networking
    ./backups.nix
    #./k8s.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
        HandlePowerKey=suspend
    '';
  };
  services.tlp.enable = lib.mkForce false;

  nix.gc.automatic = lib.mkForce false;
  /*nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "kvm-1.srv.fsn.lama-corp.space"; system = "x86_64-linux"; maxJobs = 2; speedFactor = 2; supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]; }
  ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';*/

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
    172.28.8.11 ldap.k8s.fsn.lama-corp.space
  '';

  services.spotifyd = {
    enable = true;
    config = ''
      [global]
      username = marcschmitt2@gmail.com
      password_cmd = ${pkgs.coreutils}/bin/cat ${config.sops.secrets.spotify_password.path}
      device_name = hedgehog
      device_type = computer

      bitrate = 320
    '';
  };

  systemd.services.spotifyd = let spotifydConf = pkgs.writeText "spotifyd.conf" config.services.spotifyd.config; in{
    serviceConfig = {
      User = "pulse";
      DynamicUser = lib.mkForce false;
      SupplementaryGroups = [ config.users.groups.keys.name "pulse" ];
    };
    environment = {
      SHELL = "${pkgs.bash}/bin/bash";
      PULSE_COOKIE = "/run/pulse/.config/pulse/cookie";
    };
  };

  sops.secrets.spotify_password = {
    mode = "440";
    group = config.users.groups.keys.name;
    sopsFile = ./spotifyd.yml;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
