{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  dotshabka = import ../.. { };

  haveSecrets = builtins.pathExists ./../../secrets;
in {
  imports =
    [
      <shabka/modules/nixos>

      ../../modules/nixos

      ./hardware-configuration.nix

      ./networking.nix
      ./dns-dhcp.nix

      ./home.nix
    ]
    ++ (optionals haveSecrets (singleton ./../../secrets));

  services.netdata = {
    enable = true;
  };

  services.smartd = {
    enable = true;
    extraOptions = [
      "-A /var/log/smartd/"
      "--interval=600"
    ];
    devices = [
      { device = "/dev/sda"; }
      { device = "/dev/sdb"; }
      { device = "/dev/sdc"; }
    ];
  };

  services.logrotate = {
    enable = true;
    config = ''
      compress
      /var/log/smartd/* {
        rotate 5
        weekly
        olddir /var/log/smartd/old
      }
    '';
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";
  shabka.keyboard.layouts = [ "qwerty" ];
  shabka.keyboard.enableAtBoot = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "nas.barr.srv.lama-corp.space";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "nas.barr.srv.lama-corp.space";
      }
    ];
  };

  users.users.root.hashedPassword = "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
  users.users.root.openssh.authorizedKeys.keys = (singleton dotshabka.external.risson.keys)
    ++ (singleton dotshabka.external.diego.keys);
  shabka.users.enable = true;
  shabka.users.users = {
    risson = {
      uid = 2000;
      isAdmin = true;
      home ="/home/risson";
      hashedPassword = "$6$2YnxY3Tl$kRj7YZypnB2Od41GgpwYRcn4kCcCE6OksZlKLws0rEi//T/emKWEsUZZ2ZG40eph1bpmjznztav4iKc8scmqc1";
      sshKeys = singleton dotshabka.external.risson.keys;
    };
    diego = {
      uid = 2005;
      isAdmin = true;
      home = "/home/diego";
      hashedPassword = "$6$QMhH.GTGHaI3FgjF$DFKr7yQujSyv2bPjgVdWGmqwgP5ArGmoBcAR9E9P/f9JTD2PRUtRGhOKymyWswB.Dh4JW9Vd4JZ.wz0iOOIPS/";
      sshKeys = singleton dotshabka.external.diego.keys;
    };
  };

  shabka.virtualisation = {
    docker.enable = true;
  };

  shabka.neovim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
