{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  dotshabka = import ../.. { };

in {
  imports =
    [
      <shabka/modules/nixos>

      ../../modules/nixos

      ./hardware-configuration.nix

      ./networking.nix

      ./services/web.nix

      ./home.nix
    ]
    ++ (optionals (builtins.pathExists ./../../secrets/nixos) (singleton ./../../secrets/nixos));

  shabka.hardware.machine = "hetzner-sb";

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
        comment = "duck.lama-corp.space";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "duck.lama-corp.space";
      }
    ];
  };

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
    lewdax = {
      uid = 2010;
      isAdmin = false;
      home ="/home/lewdax";
      hashedPassword = "$6$wfQaeKIxVpw/M$muMFIEm8jtjh6D1cBpax2FRQ5ocs/yjUMxZuZCMJcw55uhkuHg4oFBuJ114ELCC9q38T2NDRPxItVcRv6YSxU/";
      sshKeys = singleton dotshabka.external.lewdax.keys;
    };
  };

  users.extraUsers = {
    nixBuild = {
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGO5Ci5XecAiuS4ZN+BD3lxdRVNLqyGi/yvZcMrYU3Vy hedgehog-nixBuild"
      ];
    };
  };
  nix.trustedUsers = [ "nixBuild" ];

  shabka.virtualisation = {
    libvirtd.enable = true;
  };

  shabka.neovim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
