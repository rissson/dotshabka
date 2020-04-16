{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };
  dotshabka = import ../.. { };
in {
  imports = [
    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"

    <shabka/modules/nixos>
    ../../modules/nixos

    ./hardware-configuration.nix
    ./networking.nix

    ./home.nix
  ]
  ++ (optionals (builtins.pathExists ./../../secrets) (singleton ./../../secrets));

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.consoleFont = "Lat2-Terminus16";
  time.timeZone = "Europe/Paris";

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
    power.enable = true;
    sound.enable = true;
    teamviewer.enable = true;
    virtualbox.enable = true;
    xorg.enable = true;
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.borgbackup = {
    jobs = {
      "nas-homes" = {
        repo = "ssh://borg@172.28.2.1/./backups/homes";
        compression = "zlib,1";

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat /srv/secrets/root/backups/borg-nas-backups.passwd";
        };
        environment.BORG_RSH = "ssh -i /srv/secrets/root/backups/borg-nas-backups.ssh.key";

        paths = [
          "/home"
          "/root"
        ];

        startAt = "*-*-* 02:02:54 UTC";
        prune = {
          keep = {
            within = "1d";
            daily = 7;
            weekly = 4;
            monthly = 12;
          };
        };

        extraCreateArgs = "--stats --progress --checkpoint-interval 600";
        extraPruneArgs = "--stats --save-space --list --progress";
      };
    };
  };

  users.users.root = {
    hashedPassword = "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = with config.shabka.users.users;
      risson.sshKeys;
  };

  shabka.users.users = with dotshabka.data.users; {
    risson = {
      uid = 2000;
      isAdmin = true;
      home ="/home/risson";
      hashedPassword = risson.password;
      sshKeys = risson.keys.ssh;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
