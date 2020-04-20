{ config, ... }:

{
  users.users.root = {
    hashedPassword = "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
    openssh.authorizedKeys.keys = with config.shabka.users.users;
      risson.sshKeys ++ diego.sshKeys;
  };

  shabka.users = with import <dotshabka/data/users> {}; {
    enable = true;
    users = {
      risson = {
        inherit (risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home ="/home/risson";
      };
      diego = {
        inherit (diego) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/diego";
      };
    };
  };
}
