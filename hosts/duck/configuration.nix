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
      ./users.nix
      ./backups.nix
      ./monitoring
      ./services
      ./home
    ]
    ++ (optionals (builtins.pathExists ./../../secrets) (singleton ./../../secrets));

  shabka.hardware.machine = "hetzner_sb53";

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
        comment = "duck.srv.fsn.lama-corp.space";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = "duck.srv.fsn.lama-corp.space";
      }
    ];

    extraConfig = ''
      Match Address 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,169.254.0.0/16,fe80::/10,fd00::/8
        PermitRootLogin prohibit-password
    '';
  };

  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.neovim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
