{ config, pkgs, lib, ... }:

with lib;
with pkgs;

let
  deadd-notification-center = callPackage ./deadd-notification-center.nix {};
in
  {
    soxin.settings.keyboard.layouts = [
      {
        x11 = { layout = "us"; variant = "intl"; };
      }
    ];

    imports = [
      ./zsh
      ./python
      ./vim
      ./i3.nix
      ./sway.nix
      ./polybar.nix
    ];

    home.packages = [
    # Terminal
    terminator
    tilix
    bat
    tmux
    source-code-pro
    powerline-fonts
    direnv
    fzf
    nixpkgs-fmt
    termdown
    wyrd
    remind

    # Tools
    nix-index
    imagemagick
    pdftk
    xmind
    drawio
    pandoc
    texlive.combined.scheme-full
    cloc
    patchelf
    # Computer controls
    spectacle
    xclip
    brightnessctl
    playerctl
    redshift
    mons

    # Imaging
    feh
    vlc
    ffmpeg
    okular
    simplescreenrecorder
    aseprite
    pick-colour-picker
    krita

    # Astro
    darktable
    gphoto2
    stellarium

    # Code
    docker
    jetbrains.pycharm-professional
    SDL2
    SDL2.dev
    freetype.dev

    # General software
    libreoffice

    # Network
    openconnect
    slack
    tdesktop
    zoom-us
    spotify
    libnotify
    aerc
    deadd-notification-center
    hicolor-icon-theme  # icons for deadd-notification-center
    discord

    vscodium
    steam
    fceux  # nes emulator

    # Others
    compton
    font-awesome
  ];

  programs = {
    # git.delta.enable = true;
    git = {
      enable = true;
      userName = "ddorn";
      userEmail = "diego.dorn@free.fr";
      extraConfig = {
        core = {
          editor = "vim";
        };
        pull = {
          rebase = true;
        };
      };
    };

    firefox = {
      # enableAdobeFlash = true;
      enable = true;
    };
  };

  fonts.fontconfig.enable = true;
  gtk = {
    enable = true;
    font = {
      package = source-code-pro;
      name = "xft:SourceCodePro:style:Regular:size=9:antialias=true";
    };

    theme = {
      package = arc-theme;
      name = "Arc-Dark";
    };
  };

  home.file = {
    ".config/terminator/config".source = ./terminator.config;
  };

  xdg.configFile."ptpython/config.py".source = ./ptpython.py;

    # To have music controls through bluetooth
    systemd.user.services.mpris-proxy = {
      Unit.Description = "Mpris proxy";
      Unit.After = [ "network.target" "sound.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = [ "default.target" ];
    };


    systemd.user.services.suspend-night = let
      script = pkgs.writeShellScript "script.sh" ''
      if [ $(${pkgs.coreutils}/bin/date +"%H") -ge 21 ] || [ $(${pkgs.coreutils}/bin/date +"%H") -le 5 ]
      then
      echo "Suspending..."
      ${pkgs.systemd}/bin/systemctl suspend
      else
      echo "Not suspending..."
      fi
      '';
    in {
      Unit.Description = "Suspend the computer between 10PM and 6AM";
      Service = {
        Type = "oneshot";
        ExecStart = "${script}";
      };
    };
    systemd.user.timers.suspend-night = {
      Unit.Description = "Suspend the computer between 10PM and 6AM";
      Timer = {
        OnUnitActiveSec="5s";
        OnBootSec="5s";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  }

