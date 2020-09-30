{ lib, ... }:

with lib;

let
  backupDir = "/srv/backups";

  repos = {
    kvm-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9GpUHP1WRgwsd8sXWUC5r5AL73lcIuRr7NPenLe9xt";
    giraffe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyfCxH3k5TMkz4p7VenPmUC2+njFY/6t3e21HwxrVjG";
    hedgehog = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmVKSQfsQd8ifII8JTpRzdLYfkb0ZGGu/od8tKumnSU";
    ldap-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEulb8KXXtoaWkY8p2Mr18qQYMzD3hPW0KqavQ6E8i1D";
    mail-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwJpYOirGecmEd+tO7E8qNLQ4iTIkh7zn+L0OVyrmDo";
    minio-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtPgrdOwkfjh1Gk8A/sFC+GkwoC9kBQRwYj3RRp2Cl1";
    postgres-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/bYtJW7JXvit66uDckJ+NhoroTodLvg0MCq2pozdAm";
    web-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2Gr60YhDCP3Kz5gGhELicpmekF74tRgWTuL1XephzI";
    web-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdzrzL0JJZFc9v2eA8Q5bPQv7hSJ5SPEbQP9M8BIM/D";
  };

  mkRepo = n: v: {
    allowSubRepos = true;
    path = "${backupDir}/${n}";
    authorizedKeys = singleton v;
  };

  mkRepos = repos: mapAttrs mkRepo repos;
in {
  services.borgbackup.repos = mkRepos repos;
}
