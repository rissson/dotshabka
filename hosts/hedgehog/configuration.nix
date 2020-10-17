{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };
  nixpkgs = import shabka.external.nixpkgs.release-unstable.path { };

  nixpkgs-flakes = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-flakes";
    url = "https://github.com/NixOS/nixpkgs/archive/cc739e1c67c31fec7483137f352d32e093e40b28.tar.gz";
    sha256 = "135n5lxyh24bvsfcx1zlhzd9ciqn83plqmzv8jkxg773w8bm5smk";
  }) {};
in {
  imports = [
    <dotshabka/modules/nixos>

    ./hardware-configuration.nix
    ./networking
    ./backups.nix

    ./home.nix
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "hedgehog";
    easyCerts = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  services.tlp.enable = mkForce false;
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

  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "kvm-1.srv.fsn.lama-corp.space"; system = "x86_64-linux"; maxJobs = 2; speedFactor = 2; supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]; }
  ];

  networking.extraHosts = ''
    127.0.0.1 cri.epita.net
    127.0.0.1 lama-corp.cri.epita.net
    127.0.0.1 code.cri.epita.net
  '';

  lama-corp = {
    common.keyboard.enable = mkForce false;
    profiles.workstation = {
      enable = true;
      isLaptop = true;
      primaryUser = "risson";
    };
    luks.enable = true;
  };
  services.openssh.passwordAuthentication = mkForce false;

  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
    builders-use-substitutes = true
  '';
  nix.package = nixpkgs-flakes.nixFlakes;
  nix.gc.automatic = mkForce false;

  shabka.keyboard = {
    layouts = mkForce [ "bepo" "qwerty_intl" ];
    enableAtBoot = mkForce false;
  };

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.workstation = {
    teamviewer.enable = false;
    virtualbox.enable = mkForce false;
  };
  hardware.pulseaudio.zeroconf.discovery.enable = true;

  nixpkgs.overlays = [
    (self: super: { fprintd = nixpkgs.fprintd; })
    (self: super: { libfprint = nixpkgs.libfprint; })
    (self: super: { libpam-wrapper = nixpkgs.libpam-wrapper; })
  ];
  services.fprintd.enable = true;

  users.users.root = {
    hashedPassword = mkForce
      "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = mkForce config.shabka.users.users.risson.sshKeys;
  };

  shabka.users = with import <dotshabka/data/users> { }; {
    enable = true;
    users = {
      risson = {
        inherit (risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
