{ config, pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  makeUser = userName: { uid, isAdmin ? false, home ? "/home/${userName}", hashedPassword ? "", sshKeys ? [] }: nameValuePair
    userName
    {
      inherit home uid hashedPassword;

      group = "mine";
      extraGroups = [
        "builders"
        "dialout"
        "fuse"
        "users"
        "video"
      ]
      ++ config.shabka.users.groups
      ++ (optionals isAdmin ["wheel"]);

      shell = pkgs.zsh;
      isNormalUser = true;

      openssh.authorizedKeys.keys = sshKeys;
    };

in {
  options.shabka.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the management of users and groups.
      '';
    };

    users = mkOption {
      type = types.attrs;
      default = {};
      defaultText = ''
        The default users are ${builtins.concatStringsSep " " (builtins.attrNames defaultUsers)}
      '';
      description = ''
        The list of users to create.
      '';
    };

    groups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        The list of groups to add all users to.
      '';
    };
  };

  config = mkIf (config.shabka.users.enable) {
    users = {
      mutableUsers = false;

      groups = {
        builders = { gid = 1999; };
        mine = { gid = 2000; };
      };

      users = mapAttrs' makeUser config.shabka.users.users;
    };
  };
}
