{ soxincfg, config, lib, ... }:

{
  services.ssmtp = {
    enable = true;
    domain = "lama-corp.space";
    hostName = "mail-1.vrt.fsn.lama-corp.space";
    root = "root@lama-corp.space";
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
  };

  services.netdata = {
    enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    19999 # Netdata
  ];

  users = with soxincfg.vars.users; {
    mutableUsers = false;
    users.root = with soxincfg.vars.users.root; {
      inherit hashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  services.openssh = {
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = config.networking.fqdn;
      }
      {
        type = "ed25519";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = config.networking.fqdn;
      }
    ];
    extraConfig = ''
      StrictModes no
    '';
  };

  systemd.services.sshd.preStart = lib.mkBefore ''
    mkdir -m 0700 -p /persist/etc/ssh
  '';
}
