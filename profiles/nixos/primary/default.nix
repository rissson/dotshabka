{ soxincfg, ... }:

{
  imports = [
    ../server
  ];
  lama-corp.unbound.enable = true;

  shabka.users = {
    enable = true;
    users = {
      risson = {
        inherit (soxincfg.vars.users.risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
      diego = {
        inherit (soxincfg.vars.users.diego) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/diego";
      };
    };
  };
}
