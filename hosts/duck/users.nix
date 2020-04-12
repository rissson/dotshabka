{ config, lib, pkgs, ... }:

with lib;

let
  dotshabka = import ../.. { };
in {

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
      lewdax = {
        uid = 2010;
        isAdmin = false;
        home ="/home/lewdax";
        hashedPassword = lewdax.password;
        sshKeys = lewdax.keys.ssh;
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
