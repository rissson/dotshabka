{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./backups.nix
  ] ++ (lib.optionals (builtins.pathExists ../../secrets)
    (lib.singleton ../../secrets));

  home-manager.users.risson = import ./home.nix { inherit soxincfg; };

  #### From lama-corp modules

  # Shabka stuff

  shabka.neovim.enable = true;
  shabka.printing.enable = true;
  shabka.workstation = {
    autorandr.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    gtk.enable = true;
    power.enable = true;
    sound.enable = true;
    xorg.enable = true;
  };

  shabka.keyboard = {
    layouts = lib.mkForce [ "bepo" "qwerty_intl" ];
    enableAtBoot = lib.mkForce false;
  };

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.users = {
    enable = true;
    users = {
      risson = {
        inherit (soxincfg.vars.users.risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
    };
  };

  # Other stuff

  hardware.pulseaudio.zeroconf.discovery.enable = true;

  services.xserver = {
    videoDrivers = [ "radeon" "cirrus" "vesa" "vmware" "modesetting" "intel" ];

    displayManager.lightdm.autoLogin = lib.mkForce {
      enable = true;
      user = "risson";
    };

    xkbOptions = lib.mkForce (lib.concatStringsSep "," [ "grp:alt_caps_toggle" "caps:swapescape" ]);

    libinput.naturalScrolling = lib.mkForce false;
  };

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
        HandlePowerKey=suspend
    '';
  };

  environment.homeBinInPath = true;

  users.users.root = {
    hashedPassword = "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = config.shabka.users.users.risson.sshKeys;
  };

  services.openssh.passwordAuthentication = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "kvm-1.srv.fsn.lama-corp.space"; system = "x86_64-linux"; maxJobs = 2; speedFactor = 2; supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]; }
  ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  environment.systemPackages = with pkgs; [
    htop
    iotop
    jq
    killall
    ldns
    minio-client
    ncdu
    tcpdump
    traceroute
    tree
    unzip
    wget
    zip
  ];

  #### TESTING

  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "hedgehog";
    easyCerts = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  services.tlp.enable = lib.mkForce false;
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
