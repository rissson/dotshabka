{ soxincfg, config, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking
  ];

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
          inherit (soxincfg.vars.users.diego) hashedPassword sshKeys;
          uid = 1010;
          isAdmin = true;
          home = "/home/diego";
        };
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
