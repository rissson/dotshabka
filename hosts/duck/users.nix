{ ... }:

{
  users = {
    mutableUsers = false;

    users = {
      temp = { # Waiting for shabka to become multi-users
        createHome = true;
        hashedPassword = "";
        home = "/home/risson";
        isNormalUser = true;
        keys = import ./ssh-keys-risson.nix;
      };
    };
  };
}
