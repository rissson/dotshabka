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
    "hedgehog" = {
      allowSubRepos = true;
      path = "/srv/backups/hedgehog";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmVKSQfsQd8ifII8JTpRzdLYfkb0ZGGu/od8tKumnSU"
      ];
    };
  };

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc -v";
    frequent = 4;
    hourly = 24;
    daily = 7;
    weekly = 4;
    monthly = 12;
  };
}
