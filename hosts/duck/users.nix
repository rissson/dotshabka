{ config, lib, pkgs, ... }:

with lib;

{
  shabka.users = with import <dotshabka/data/users> {}; {
    users = {
      lewdax = {
        inherit (lewdax) uid hashedPassword sshKeys;
        isAdmin = false;
        home ="/home/lewdax";
      };
    };
  };

  users.extraUsers = {
    "gitlabci" = {
      home = "/srv";
      isSystemUser = true;
      group = "deploy";
      packages = with pkgs; [ rsync ];
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEfjcrIG01Wh266+cEL3ib80dJkyYxoMVFUaxQch1xnv" ];
    };
  };

  users.extraGroups = {
    "deploy" = {};
  };
}
