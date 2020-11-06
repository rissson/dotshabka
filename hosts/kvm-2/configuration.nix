{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking
  ];

  lama-corp = {
    virtualisation = {
      libvirtd = {
        enable = true;
        images = [ "nixos" ];
      };
    };
  };

  soxin = {
    services = {
      openssh.enable = true;
    };

    programs = {
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

    hardware = {
      enable = true;
    };

    users = {
      enable = true;
      users = {
        risson = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1000;
          isAdmin = true;
          home = "/home/risson";
        };
        diego = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1010;
          isAdmin = true;
          home = "/home/diego";
        };
      };
    };
  };

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "$6$S6p2F9bVh$kPWZhtZ2gvlcn5G4L5iU3lujzEyCPa8XxPz2TGgsudpOz3O/.dRqh4le6qNKCBmlIDzlox19S7k2ehFPZqGto.";
      openssh.authorizedKeys.keys = with soxincfg.vars.users; risson.sshKeys ++ diego.sshKeys;
    };
  };

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
    extraConfig = ''
      StrictModes no
    '';
  };

  systemd.services.sshd.preStart = lib.mkBefore ''
    mkdir -m 0700 -p /persist/etc/ssh
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
    fio
    ioping
  ];

  services.netdata.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
