{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> {};
  dotshabka = import <dotshabka> {};
in {
  imports =
    [
      <shabka/modules/nixos>
      ../../modules/nixos

      ./hardware-configuration.nix
      ./networking.nix
      ./dns-dhcp.nix
      ./home
    ]
    ++ (optionals (builtins.pathExists ./../../secrets) (singleton ./../../secrets));

    # TODO: move this to a monitoring folder
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

  # TODO: package this and run it as a service
  docker-containers."cloudflare-ddns-ipv4" = {
    image = "oznu/cloudflare-ddns";
    environment = {
      ZONE = "lama-corp.space";
      SUBDOMAIN = "bar";
      PROXIED = "false";
      RRTYPE = "A";
    };
    extraDockerOptions = [
      "--network=host"
    ];
  };

  docker-containers."cloudflare-ddns-ipv6" = {
    image = "oznu/cloudflare-ddns";
    environment = {
      ZONE = "lama-corp.space";
      SUBDOMAIN = "bar";
      PROXIED = "false";
      RRTYPE = "AAAA";
    };
    extraDockerOptions = [
      "--network=host"
    ];
  };

  services.borgbackup.repos = {
    "duck" = {
      allowSubRepos = true;
      path = "/srv/backups/duck";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9GpUHP1WRgwsd8sXWUC5r5AL73lcIuRr7NPenLe9xt"
      ];
    };
    "hedgehog" = {
      allowSubRepos = true;
      path = "/srv/backups/hedgehog";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmVKSQfsQd8ifII8JTpRzdLYfkb0ZGGu/od8tKumnSU"
      ];
    };
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
        comment = "nas.bar.srv.lama-corp.space";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "nas.bar.srv.lama-corp.space";
      }
    ];

    extraConfig = ''
      Match Address 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,169.254.0.0/16,fe80::/10,fd00::/8
        PermitRootLogin prohibit-password
    '';
  };

  # TODO: move this to a users.nix as in duck's config
  users.users.root = {
    hashedPassword = "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
    openssh.authorizedKeys.keys = with config.shabka.users.users;
      risson.sshKeys ++ diego.sshKeys;
  };

  shabka.users = with dotshabka.data.users; {
    enable = true;
    users = {
      risson = {
        uid = 2000;
        isAdmin = true;
        home ="/home/risson";
        hashedPassword = risson.password;
        sshKeys = risson.keys.ssh;
      };
      diego = {
        uid = 2005;
        isAdmin = true;
        home = "/home/diego";
        hashedPassword = diego.password;
        sshKeys = diego.keys.ssh;
      };
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
  system.stateVersion = "20.03"; # Did you read the comment?
}
