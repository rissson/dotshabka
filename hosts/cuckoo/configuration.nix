{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  dotshabka = import ../.. { };

  haveSecrets = builtins.pathExists ./../../secrets;
in {
  imports = [
    "${shabka.external.nixos-hardware.path}/common/cpu/intel"

    <shabka/modules/nixos>

    ../../modules/nixos

    ./hardware-configuration.nix

    ./home.nix
  ]
  ++ (optionals haveSecrets (singleton ./../../secrets));

  networking.hostName = "cuckoo";
  networking.domain = "srv.bar.lama-corp.space";
  networking.useDHCP = false;
  networking.interfaces."enp4s11".useDHCP = true;
  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [
      22 # SSH
      3389 # Spotifyd
      57621 # Spotifyd
    ];
    allowedUDPPorts = [ ] ++ (optionals config.networking.wireguard.enable (singleton 51820)); # Wireguard

    allowedTCPPortRanges = [ ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };

  nixpkgs.config.allowUnfree = true; # For spotify

  # TODO: add spotifyd
  sound.enable = true;
  # TODO: add support for TCP streams
  hardware.pulseaudio.enable = true;

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
        comment = "cuckoo.srv.bar.lama-corp.space";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "cuckoo.srv.bar.lama-corp.space";
      }
    ];

    extraConfig = ''
      Match Address 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,169.254.0.0/16,fe80::/10,fd00::/8
        PermitRootLogin prohibit-password
    '';
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
  };

  shabka.neovim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
