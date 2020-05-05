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
    "minio-1" = {
      allowSubRepos = true;
      path = "/srv/backups/minio-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtPgrdOwkfjh1Gk8A/sFC+GkwoC9kBQRwYj3RRp2Cl1"
      ];
    };
    "postgres-1" = {
      allowSubRepos = true;
      path = "/srv/backups/postgres-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/bYtJW7JXvit66uDckJ+NhoroTodLvg0MCq2pozdAm"
      ];
    };
    "reverse-1" = {
      allowSubRepos = true;
      path = "/srv/backups/reverse-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuMqQj/mVgnfSc2aXDiu1qXfArpJ5ORXecRDHT2rUgs"
      ];
    };
    "web-1" = {
      allowSubRepos = true;
      path = "/srv/backups/web-1";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Gr60YhDCP3Kz5gGhELicpmekF74tRgWTuL1XephzI"
      ];
    };
    "web-2" = {
      allowSubRepos = true;
      path = "/srv/backups/web-2";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdzrzL0JJZFc9v2eA8Q5bPQv7hSJ5SPEbQP9M8BIM/D"
      ];
    };
  };
}
