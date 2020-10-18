{ soxincfg }:
{ nixosConfig, config, lib, pkgs, ... }:

with lib;

{
  imports = [ soxincfg.homeModules.shabka ];

  shabka.nixosConfig = nixosConfig;
  shabka.git = {
    userName = "Marc 'risson' Schmitt";
    userEmail = "marc.schmitt@risson.space";
    gpgSigningKey = "marc.schmitt@risson.space";
  };
  shabka.keyboard.layouts = [ "bepo" "qwerty_intl" ];
  shabka.batteryNotifier.enable = true;
  shabka.fzf.enable = true;
  shabka.git.enable = true;
  shabka.gnupg.enable = true;
  shabka.htop.enable = true;
  shabka.keybase.enable = true;
  shabka.ssh.enable = true;
  shabka.tmux.enable = true;
  shabka.neovim.enable = true;
  shabka.neovim.keyboardLayout = "qwerty";
  shabka.workstation = {
    enable = true;
    autorandr.enable = true;
    dunst.enable = true;
    i3 = {
      enable = true;
      bar = {
        polybar.enable = true;
        location = "top";
        modules = {
          backlight.enable = true;
          battery = {
            enable = true;
            devices = [{
              device = "BAT0";
              fullAt = 97;
            }];
          };
          cpu.enable = true;
          time = {
            enable = true;
            timezones = [
              {
                timezone = "Europe/Paris";
                prefix = "FR";
                format = "%a %Y-%m-%d %H:%M:%S";
              }
              {
                timezone = "UTC";
                prefix = "UTC";
                format = "%H:%M:%S";
              }
            ];
          };
          ram.enable = true;
          network = {
            enable = true;
            eth = [ "enp4s0" "enp3s0f0" "enp0s20f0u2u2" "enp0s20f0u1u1" ];
            wlan = [ "wlp1s0" ];
          };
          volume.enable = true;
          spotify.enable = false;
          keyboardLayout.enable = true;
        };
      };
    };
    rofi.enable = true;
    urxvt.enable = true;
    bluetooth.enable = true;
    gtk.enable = true;
    locker.enable = true;
  };

  programs.command-not-found.enable = true;
  shabka.neovim = {
    extraRC = mkForce ''
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


  programs.gpg = {
    enable = true;
    settings = {
      throw-keyids = true;
      keyserver = "hkps://keys.openpgp.org";
    };
  };

  programs.git.package = mkForce pkgs.gitAndTools.gitFull;
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

  programs.urxvt.extraConfig.termName = "rxvt-256color";
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

  ## TBD once fixed in shabka
  home.file.".mozilla/firefox/profiles/epita/.keep".text = "";
  home.file.".mozilla/firefox/profiles/lamacorp/.keep".text = "";
  home.file.".mozilla/firefox/profiles/personal/.keep".text = "";
  home.file.".mozilla/firefox/profiles.ini".text = ''
    [General]
    StartWithLastProfile=1

    [Profile0]
    Name=personal
    IsRelative=1
    Path=profiles/personal
    Default=1

    [Profile1]
    Name=profiles/epita
    IsRelative=1
    Path=epita

    [Profile2]
    Name=lamacorp
    IsRelative=1
    Path=profiles/lamacorp
  '';
  ## END TBD

  xresources = {
    properties = {
      "*foreground" = "#b2b2b2";
      "*background" = "#020202";
    };
  };

  programs.autorandr.profiles = {
    "default" = {
      fingerprint = {
        eDP-1 =
          "00ffffffffffff0030aeba4000000000001b0104a5221378eacde5955b558f271d505400000001010101010101010101010101010101243680a070381f403020350058c210000019502b80a070381f403020350058c2100000190000000f00d10932d10930190a0030e4ba05000000fe004c503135365746392d53504b33002c";
      };

      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1080";
          gamma = "1.0:0.909:0.909";
          rate = "59.98";
        };
      };
    };

    "home" = {
      fingerprint = {
        eDP-1 =
          "00ffffffffffff0030aeba4000000000001b0104a5221378eacde5955b558f271d505400000001010101010101010101010101010101243680a070381f403020350058c210000019502b80a070381f403020350058c2100000190000000f00d10932d10930190a0030e4ba05000000fe004c503135365746392d53504b33002c";
        HDMI-1 =
          "00ffffffffffff000472f901b67160121a150103a0331d78baee91a3544c99260f5054b30c00714f818095008100d1c0010101010101023a801871382d40582c4500fe1f1100001e000000fd00324c1e5011000a202020202020000000ff005133543038303032343230320a000000fc00416365722045323330480a202001dd02031b71230907078301000067030c001000802143011084e2000f011d007251d01e206e28550081490000001e00000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000000000000000000bf";
        DP-1 =
          "00ffffffffffff000469d5196da101002213010308291a78ea8585a6574a9c26125054bfef80714f8100810f814081809500950f01019a29a0d0518422305098360098ff1000001c000000fd00374b1e530f000a202020202020000000fc0041535553205657313933440a20000000ff0039384c4d54463130363836310a00fa";
      };

      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          position = "1920x0";
          mode = "1920x1080";
          gamma = "1.0:0.909:0.909";
          rate = "59.98";
        };
        HDMI-1 = {
          enable = true;
          primary = false;
          position = "0x0";
          mode = "1920x1080";
          gamma = "1.0:0.909:0.909";
          rate = "60.00";
        };
        DP-1 = {
          enable = true;
          primary = false;
          position = "3840x0";
          mode = "1440x900";
          gamma = "1.0:0.909:0.909";
          rate = "59.89";
        };
      };
    };
  };

  programs.taskwarrior = {
    enable = true;
    extraConfig = ''
      # Urgency settings
      urgency.user.tag.bug.coefficient=5.0
      urgency.user.tag.problem.coefficient=4.5
      urgency.user.tag.later.coefficient=-6.0
      urgency.user.tag.waiting.coefficient=-12.0
      urgency.user.tag.backlog.coefficient=-20.0

      # UDA settings for tasksh
      uda.reviewed.type=date
      uda.reviewed.label=Reviewed
      # Report settings
      report._reviewed.description=Tasksh review report. Adjust the filter to your needs.
      report._reviewed.columns=uuid
      report._reviewed.sort=reviewed+,modified+
      report._reviewed.filter=( reviewed.none: or reviewed.before:now-1week ) and ( +PENDING or +WAITING )
      taskd.certificate=/home/risson/.task/keys/public.cert
      taskd.key=/home/risson/.task/keys/private.key
      taskd.ca=/home/risson/.task/keys/ca.cert
      taskd.credentials=lama-corp/risson/031459a4-0739-4ff9-a0cd-44c20a271172
      taskd.server=kvm-1.srv.fsn.lama-corp.space:53589
    '';
  };


  home.packages = with pkgs; [
    thunderbird
  ];

  services.random-background = {
    enable = true;
    enableXinerama = true;
    display = "center";
    imageDirectory = "%h/.background-images";
    interval = "1h";
  };

  gtk = lib.mkForce {
    enable = true;
    font = {
      package = pkgs.hack-font;
      name = "xft:SourceCodePro:style:Regular:size=9:antialias=true";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-dark";
    };
  };

  services.screen-locker.lockCmd =
    let
      script = pkgs.writeTextFile {
        name = "lock.sh";
        executable = true;
        destination = "/bin/lock.sh";
        text = ''
          #! ${pkgs.runtimeShell}
          ${pkgs.i3lock-color}/bin/i3lock-color --clock --color=ffa500 --show-failed-attempts --bar-indicator --datestr='%A %Y-%m-%d' -i $(${pkgs.coreutils}/bin/shuf -n1 -e /home/risson/.lock-images/*.jpg)
        '';
      };
    in
    lib.mkForce "${script}/bin/lock.sh";

  home.keyboard.options = [ "grp:alt_caps_toggle" "caps:swapescape" ];

  home.sessionVariables.DOTSHABKA_PATH = "/home/risson/lama-corp/infra/dotshabka";


}
