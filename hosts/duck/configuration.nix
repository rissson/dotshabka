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

      ./services/web.nix

      ./home.nix
    ];

  shabka.hardware.machine = "hetzner_cloud";

  networking.hostName = "duck";
  networking.nameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];

  networking.defaultGateway = {
    address = "172.31.1.1";
    interface = "ens3";
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };
  networking.interfaces = [
    {
      name = "ens3";
      ipv4 = {
        addresses = [
          { address = "116.203.140.35"; prefixLength = 32; }
          { address = "116.203.7.71"; prefixLength = 32; }
          { address = "116.203.8.117"; prefixLength = 32; }
        ];
      };
      ipv6 = {
        addresses = [
          { address = "2a01:4f8:c2c:5530::1"; prefixLength = 64; }
          { address = "2a01:4f8:c2c:5530::2"; prefixLength = 64; }
          { address = "2a01:4f8:c2c:5530::3"; prefixLength = 64; }
        ];
      };
    }
  ];

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ ];

    allowedTCPPortRanges = [
      { from = 8001; to = 8002; } # weechat
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";
  shabka.keyboard.layouts = [ "qwerty" ];
  shabka.keyboard.enableAtBoot = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
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

  users.users.root.openssh.authorizedKeys.keys = singleton dotshabka.external.risson.keys;
  shabka.users.users = {
    risson = {
      uid = 2000;
      isAdmin = true;
      home ="/home/risson";
      hashedPassword = "$6$2YnxY3Tl$kRj7YZypnB2Od41GgpwYRcn4kCcCE6OksZlKLws0rEi//T/emKWEsUZZ2ZG40eph1bpmjznztav4iKc8scmqc1";
      sshKeys = singleton dotshabka.external.risson.keys;
    };
    lewdax = {
      uid = 2100;
      isAdmin = false;
      home ="/home/lewdax";
      hashedPassword = "$6$wfQaeKIxVpw/M$muMFIEm8jtjh6D1cBpax2FRQ5ocs/yjUMxZuZCMJcw55uhkuHg4oFBuJ114ELCC9q38T2NDRPxItVcRv6YSxU/";
      sshKeys = singleton dotshabka.external.lewdax.keys;
    };
  };


  shabka.users.enable = true;
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
