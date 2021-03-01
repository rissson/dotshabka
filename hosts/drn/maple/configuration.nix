{ soxincfg, config, pkgs, lib, ... }:
let
  useSway = false;
in
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    (import ./sway.nix { inherit useSway; })
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Source Code Pro" ];
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
  nix.gc.automatic = lib.mkForce false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim ranger bat tmux
    source-code-pro powerline-fonts
  ];
  environment.pathsToLink = [ "/share/zsh" ];
  programs.dconf.enable = true;

  services.fprintd.enable = true;

  # Battery management
  services.upower.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuRunAsRoot = false;
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    autorun = true;
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 30;
    xkbOptions = lib.concatStringsSep "," [
      "caps:swapescape"
      "compose:ralt"
    ];

    libinput.enable = true;
    libinput.naturalScrolling = false;

    displayManager.defaultSession = if useSway then "sway" else "none+i3";
    displayManager.lightdm.enable = true;
    displayManager.lightdm.autoLogin = {
      enable = true;
      user = "diego";
    };

    windowManager.i3.enable = !useSway;
    windowManager.i3.package = pkgs.i3-gaps;
    videoDrivers = [ "intel" ];
  };

  soxin = {
    users = {
      enable = true;
      users = {
        diego = {
          inherit (soxincfg.vars.users.diego) uid hashedPassword sshKeys;
          isAdmin = true;
          home = "/home/diego";
        };
      };
      groups = [
        "builders"
        "dialout"
        "fuse"
        "users"
        "video"
        "wheel"
        "libvertd"
        "vboxusers"
        "sway"
        "docker"
      ];
    };
  };

  users.users.root = {
    hashedPassword = "$6$OEjyCBS10p$XXt7VqtYhYWFQowNcHR3b61.17IwMfi2YVYB0c8pl8koqE2INzJApzAABUpPnpRSqBW778d9xZrvrt1QHkuZI/";
    openssh.authorizedKeys.keys = config.soxin.users.users.diego.sshKeys;
  };

  home-manager.users.diego = import ./home;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
