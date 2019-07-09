{ config, pkgs, lib, ... }:

with lib;


let
  shabka = import <shabka> { };

  dotshabka = import ../../.. { };

in {
  config = {
    users.users.root.openssh.authorizedKeys.keys = singleton dotshabka.external.risson.keys;
    shabka.users.users = {
      risson = {
        uid = 2000;
        isAdmin = true;
        home ="/home/risson";
        hashedPassword = "$6$2YnxY3Tl$kRj7YZypnB2Od41GgpwYRcn4kCcCE6OksZlKLws0rEi//T/emKWEsUZZ2ZG40eph1bpmjznztav4iKc8scmqc1";
        sshKeys = singleton dotshabka.external.risson.keys;
      };
    };
  };
}
