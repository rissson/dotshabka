{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.primary;
in {
  options = {
    lama-corp.profiles.primary.enable = mkEnableOption "Enable profile for primary hosts";
  };

  config = mkIf cfg.enable {
    lama-corp.profiles.server.enable = true;

    lama-corp.unbound.enable = true;

    shabka.users = with import <dotshabka/data/users> { }; {
      enable = true;
      users = {
        risson = {
          inherit (risson) uid hashedPassword sshKeys;
          isAdmin = true;
          home = "/home/risson";
        };
        diego = {
          inherit (diego) uid hashedPassword sshKeys;
          isAdmin = true;
          home = "/home/diego";
        };
      };
    };
  };
}
