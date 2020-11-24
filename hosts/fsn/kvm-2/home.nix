{ soxincfg }:
{ nixosConfig, config, lib, pkgs, ... }:

with lib;

{
  soxin = {
    settings = {
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

    programs = {
      fzf.enable = true;
      git = {
        enable = true;
        userName = "Marc 'risson' Schmitt";
        userEmail = "marc.schmitt@risson.space";
        gpgSigningKey = "marc.schmitt@risson.space";
      };
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
  };

  programs.command-not-found.enable = true;

  programs.gpg = {
    enable = true;
    settings = {
      throw-keyids = true;
      keyserver = "hkps://keys.openpgp.org";
    };
  };

  programs.git.aliases = {
    b         = "branch";
    ci        = mkForce "commit -s";
    ciam      = mkForce "commit -a -s -m";
    cim       = mkForce "commit -s -m";
    coke      = "commit -a -s -m";
    cokewogpg = "commit --no-gpg-sign -a -s -m";
  };

  programs.git.extraConfig = {
    branch = {
      autosetuprebase = "always";
    };

    core = {
      editor = "vim";
    };

    format = {
      signOff = true;
    };

    push = {
      default = "simple";
    };

    pull = {
      rebase = true;
    };
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/cri/";
      contents = {
        user = {
          email = "risson@cri.epita.fr";
          signingkey = "risson@cri.epita.fr";
        };
      };
    }
    {
      condition = "gitdir:~/prologin/";
      contents = {
        user = {
          email = "marc.schmitt@prologin.org";
          signingkey = "marc.schmitt@prologin.org";
        };
      };
    }
    {
      condition = "gitdir:~/lama-corp/";
      contents = {
        user = {
          email = "marc.schmitt@lama-corp.space";
          signingkey = "marc.schmitt@lama-corp.space";
        };
      };
    }
  ];

  programs.ssh = {
    matchBlocks = {
      ### Lama Corp.
      "kvm-1" = {
        hostname = "kvm-1.srv.fsn.lama-corp.space";
      };
      "*.fsn" = {
        user = "root";
        hostname = "%h.lama-corp.space";
        proxyJump = "kvm-1";
      };
      "*.bar" = {
        user = "root";
        hostname = "%h.lama-corp.space";
        proxyJump = "kvm-1";
      };
      "*.nbg" = {
        user = "root";
        hostname = "%h.lama-corp.space";
        proxyJump = "kvm-1";
      };

      ### CRI
      "goat" = {
        user = "risson";
        hostname = "gate.cri.epita.fr";
        port = 22450;
      };

      "git.cri.epita.fr" = {
        user = "git";
        extraOptions = {
          controlMaster = "yes";
          controlPersist = "2m";
        };
      };

      # Git hosting
      "gitlab" = {
        hostname = "gitlab.com";
        user = "git";
      };
      "github" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };

  home.packages = with pkgs; [
    jq
    killall
    nur.repos.kalbasit.nixify
    nix-index
    unzip
    nix-zsh-completions
  ];

  programs.bat.enable = true;
  programs.direnv.enable = true;

  home.sessionVariables.DOTSHABKA_PATH = "/home/risson/lama-corp/infra/dotshabka";
}
