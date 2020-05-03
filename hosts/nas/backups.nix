{ ... }:

{
  services.borgbackup.repos = {
    "duck" = {
      allowSubRepos = true;
      path = "/srv/backups/duck";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9GpUHP1WRgwsd8sXWUC5r5AL73lcIuRr7NPenLe9xt"
      ];
    };
    "giraffe" = {
      allowSubRepos = true;
      path = "/srv/backups/giraffe";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyfCxH3k5TMkz4p7VenPmUC2+njFY/6t3e21HwxrVjG"
      ];
    };
    "hedgehog" = {
      allowSubRepos = true;
      path = "/srv/backups/hedgehog";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmVKSQfsQd8ifII8JTpRzdLYfkb0ZGGu/od8tKumnSU"
      ];
    };
    "ldap-1" = {
      allowSubRepos = true;
      path = "/srv/backups/ldap-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEulb8KXXtoaWkY8p2Mr18qQYMzD3hPW0KqavQ6E8i1D"
      ];
    };
    "mail-1" = {
      allowSubRepos = true;
      path = "/srv/backups/mail-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwJpYOirGecmEd+tO7E8qNLQ4iTIkh7zn+L0OVyrmDo"
      ];
    };
    "reverse-1" = {
      allowSubRepos = true;
      path = "/srv/backups/reverse-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuMqQj/mVgnfSc2aXDiu1qXfArpJ5ORXecRDHT2rUgs"
      ];
    };
  };
}
