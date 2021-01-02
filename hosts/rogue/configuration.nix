{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking
  ];

  home-manager.users.risson = import ./home.nix { inherit soxincfg; };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

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
        images = [ "nixos" ];
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

  services.tlp.enable = lib.mkForce false;

  services.netdata.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
      {
        type = "ed25519";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
    ];
  };

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
