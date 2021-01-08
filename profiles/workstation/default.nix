{ soxincfg, userName, config, lib, ... }:

{
  imports = [
    ./krb5.nix
  ];

  config = lib.mkMerge [
    {
      documentation = {
        dev.enable = true;
        man.generateCaches = true;
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

      environment.homeBinInPath = true;
    }

    (lib.optionalAttrs (userName == "risson") {
      home-manager.users.risson = import ./home/risson;

      users.users.root = {
        hashedPassword = "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
        openssh.authorizedKeys.keys = config.soxin.users.users.risson.sshKeys;
      };

      hardware.pulseaudio.zeroconf.discovery.enable = true;

      console.keyMap = lib.mkForce "us";

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

      lama-corp = {
        virtualisation = {
          libvirtd = {
            enable = true;
            images = [ "nixos" ];
          };
        };
      };
    })
  ];
}
