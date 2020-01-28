{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  dotshabka = import ../.. { };

in {
  imports = [
    ./hardware-configuration.nix

    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"

    <shabka/modules/nixos>
    ../../modules/nixos

    ./home.nix
  ]
  ++ (optionals (builtins.pathExists ./../../secrets) (singleton ./../../secrets));

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  networking.hostName = "hedgehog";
  networking.domain = "lama-corp.space";

  networking.wireguard = {
    enable = false; # Is enabled by secrets if they are present.
    interfaces = {
      "wg0" = {
        ips = [ "10.100.6.1/32" ];

        peers = [
          {
            publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
            allowedIPs = [ "10.100.0.0/16" ];
            endpoint = "148.251.50.190:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  shabka.hardware.intel_backlight.enable = true;
  shabka.printing.enable = true;
  shabka.users.enable = true;
  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.keyboard.layouts = [ "bepo" "qwerty_intl" ];
  shabka.keyboard.enableAtBoot = false;

  shabka.workstation = {
    autorandr.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    networking.enable = true;
    power.enable = true;
    sound.enable = true;
    teamviewer.enable = true;
    virtualbox.enable = true;
    xorg.enable = true;
  };

  shabka.hardware.machine = "thinkpad-e580";

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  users.users.root.openssh.authorizedKeys.keys = singleton dotshabka.external.risson.keys;
  shabka.users.users = {
    risson = {
      uid = 2000;
      isAdmin = true;
      home ="/home/risson";
      hashedPassword = "$6$2YnxY3Tl$kRj7YZypnB2Od41GgpwYRcn4kCcCE6OksZlKLws0rEi//T/emKWEsUZZ2ZG40eph1bpmjznztav4iKc8scmqc1";
      sshKeys = singleton dotshabka.external.risson.keys;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
