{ config, pkgs, lib, soxincfg, ... }:

with lib;

{
  imports = [
    # TODO: lama-corp modules
    ./hardware-configuration.nix
    ./networking
    ./backups.nix

    #./home.nix
  ];
  # TODO: add secrets

  /*lama-corp = {
    common.keyboard.enable = mkForce false;
    profiles.workstation = {
      enable = true;
      isLaptop = true;
      primaryUser = "risson";
    };
    luks.enable = true;
  };*/
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  nix = {
    autoOptimiseStore = true;
    buildCores = 0;
    daemonIONiceLevel = 7;
    daemonNiceLevel = 10;
    distributedBuilds = true;
    useSandbox = true;
    gc.automatic = mkForce false;

    extraOptions = ''
      auto-optimise-store = true
    '';

    optimise = {
      automatic = true;
      dates = [ "12:00" ];
    };

    trustedUsers = [
      "root" "@wheel" "@builders"
    ];
  };

  security.hideProcessInformation = true;

  console = {
    earlySetup = false;
    keyMap = "fr-bepo";
  };

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemuRunAsRoot = false;
    };
  };

  services.pcscd.enable = true;
  security.pam.u2f = {
    enable = true;
    cue = true;
  };

  environment.variables.EDITOR = "nvim";
  environment.variables.BROWSER = "${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser";
  home-manager.useUserPackages = true;

  services.xserver = {
    autorun = true;
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 30;
    layout = "fr,us";
    xkbVariant = "bepo,intl";
    xkbOptions = concatStringsSep "," [
      "ctrl:nocaps"
    ];
    libinput.enable = true;
    libinput.naturalScrolling = true;
    displayManager.defaultSession = "none+i3";
    displayManager.lightdm.enable = true;

    displayManager.autoLogin = {
      enable = true;
      user = "risson";
    };

    windowManager.i3.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.zeroconf.discovery.enable = true;

  services.fwupd.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr
      hplip
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # install all completions libraries for system packages
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  services.autorandr.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      powerline-fonts
      twemoji-color-font
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk
      symbola
      vegur
      b612
    ];
  };

  # GTK
  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  environment.systemPackages = with pkgs; [
    git
    (curl.override {
      brotliSupport = true;
    })
    tmux
    mosh
    pavucontrol pa_applet
    yubico-piv-tool yubikey-manager yubikey-neo-manager yubikey-personalization
    yubikey-personalization-gui yubioath-desktop
  ];

  # TODO: neovim, tmux

  users = {
    mutableUsers = false;
    groups = {
      builders = { gid = 1999; };
      mine = { gid = 2000; };
    };
    users = with soxincfg.vars.users; {
      root = {
        hashedPassword = mkForce "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
        openssh.authorizedKeys.keys = mkForce config.users.users.risson.openssh.authorizedKeys.keys;
      };
      risson = {
        inherit (risson) uid hashedPassword;
        home = "/home/risson";
        group = "mine";
        extraGroups = [
          "builders"
          "dialout"
          "fuse"
          "users"
          "video"
          "docker"
          "wheel"
          "libvirtd"
        ];
        shell = pkgs.zsh;
        isNormalUser = true;
        openssh.authorizedKeys.keys = risson.sshKeys;
      };
    };
  };

  home-manager.users = {
    # TODO
    #risson = import ./home;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
