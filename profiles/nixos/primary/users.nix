{ ... }:

{
  shabka.users = with import <dotshabka/data/users> { }; {
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
}
