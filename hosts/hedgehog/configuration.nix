{ soxincfg, config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./hardware-configuration.nix
    ./networking
    ./backups.nix
    #./k8s.nix
  ] ++ (lib.optionals (builtins.pathExists ../../secrets)
  (lib.singleton ../../secrets));

  home-manager.users.risson = import ./home.nix { inherit soxincfg; };

  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "LAMA-CORP.SPACE";
      dns_fallback = true;
      dns_canonicalize_hostname = false;
      rnds = false;
    };

    realms = {
      "LAMA-CORP.SPACE" = {
        admin_server = "kerberos.lama-corp.space";
      };
    };
  };

  lama-corp = {
    virtualisation = {
      libvirtd = {
        enable = true;
        #images = [ "nixos" ];
      };
    };
  };

  soxin = {
    hardware.bluetooth.enable = true;

    settings = {
      fonts.enable = true;
      gtk.enable = true;
      keyboard = {
        layouts = [
          {
            x11 = { layout = "fr"; variant = "bepo"; };
            console.keyMap = "fr-bepo";
          }
          {
            x11 = { layout = "us"; variant = "intl"; };
          }
        ];
      };
    };

    services = {
      gpgAgent.enable = true;
      openssh.enable = true;
      printing = {
        enable = true;
        brands = [ "hp" ];
      };
      xserver.enable = true;
    };

    programs = {
      autorandr.enable = true;
      git.enable = true;
      htop.enable = true;
      mosh.enable = true;
      neovim = {
        enable = true;
        extraRC = ''
          set background=dark
          colorscheme gruvbox
          let g:airline_theme='gruvbox'

          " set the mapleader
          let mapleader = " "
          " Whitespace
          set expandtab    " don't use tabs
          set shiftwidth=4 " Number of spaces to use for each step of (auto)indent.
          set softtabstop=8    " Number of spaces that a <Tab> in the file counts for.
          autocmd Filetype make setlocal noexpandtab " don't expand in makefiles

          set listchars=tab:»·              " a tab should display as "»·"
          set listchars+=trail:·            " show trailing spaces as dots
        '';
      };
      ssh.enable = true;
      starship.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };

    virtualisation = {
      docker.enable = true;
    };

    hardware = {
      enable = true;
      intelBacklight.enable = true;
      sound.enable = true;
      yubikey.enable = true;
    };

    users = {
      enable = true;
      users = {
        risson = {
          inherit (soxincfg.vars.users.risson) uid hashedPassword sshKeys;
          isAdmin = true;
          home = "/home/risson";
        };
      };
    };
  };

  console.keyMap = lib.mkForce "us";

  # Other stuff

  hardware.pulseaudio.zeroconf.discovery.enable = true;

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
    openssh.authorizedKeys.keys = config.soxin.users.users.risson.sshKeys;
  };

  nix.gc.automatic = lib.mkForce false;
  /*nix.distributedBuilds = true;
  nix.buildMachines = [
  { hostName = "kvm-1.srv.fsn.lama-corp.space"; system = "x86_64-linux"; maxJobs = 2; speedFactor = 2; supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]; }
  ];
  nix.extraOptions = ''
  builders-use-substitutes = true
  '';*/

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

  services.netdata.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/srv/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
      {
        type = "ed25519";
        path = "/srv/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
    ];
  };

  networking.firewall.enable = lib.mkForce false;
  networking.extraHosts = ''
    127.0.0.1 cri.epita.net
    127.0.0.1 lama-corp.cri.epita.net
    127.0.0.1 code.cri.epita.net
    172.28.8.11 ldap.k8s.fsn.lama-corp.space
  '';

  documentation = {
    enable = false;
    #dev.enable = true;
    #man.generateCaches = true;
    nixos.enable = false;
  };

  users.motd = "bite";

  security.pam = {
    services.myService = {
      excludeDefaults = [ "auth" "session" "account" ];
      account = {
        myEntry = {
          control = "optional";
          path = "my_entry.so";
          order = 200;
        };
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
