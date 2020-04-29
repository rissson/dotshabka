{ config, ... }:

{
  users.users.root = with import <dotshabka/data/users> {}; {
    hashedPassword = "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
    openssh.authorizedKeys.keys = risson.sshKeys ++ diego.sshKeys;
  };
}
