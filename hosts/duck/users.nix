{ lib, pkgs, ... }:

with lib;

let

  dotshabka = import ../.. { };

in {
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
    diego = {
      uid = 2005;
      isAdmin = true;
      home = "/home/diego";
      hashedPassword = "$6$QMhH.GTGHaI3FgjF$DFKr7yQujSyv2bPjgVdWGmqwgP5ArGmoBcAR9E9P/f9JTD2PRUtRGhOKymyWswB.Dh4JW9Vd4JZ.wz0iOOIPS/";
      sshKeys = singleton dotshabka.external.diego.keys;
    };
    lewdax = {
      uid = 2010;
      isAdmin = false;
      home ="/home/lewdax";
      hashedPassword = "$6$wfQaeKIxVpw/M$muMFIEm8jtjh6D1cBpax2FRQ5ocs/yjUMxZuZCMJcw55uhkuHg4oFBuJ114ELCC9q38T2NDRPxItVcRv6YSxU/";
      sshKeys = singleton dotshabka.external.lewdax.keys;
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
