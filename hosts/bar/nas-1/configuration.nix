{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking
    ./backups
    ./nginx.nix
    ./prometheus.nix
    ./grafana.nix
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/${config.services.prometheus.stateDir}"
      config.services.grafana.dataDir
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  soxin = {
    users = {
      enable = true;
      users = {
        risson = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1000;
          isAdmin = true;
          home = "/home/risson";
        };
        diego = {
          inherit (soxincfg.vars.users.risson) hashedPassword sshKeys;
          uid = 1010;
          isAdmin = true;
          home = "/home/diego";
        };
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
