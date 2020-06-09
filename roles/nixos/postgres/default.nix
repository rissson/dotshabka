{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    enableTCPIP = true;
    dataDir = "/srv/postgresql/11";
    authentication = ''
      local all all                       ident
      host  all all 127.0.0.1/32          md5
      host  all all ::1/128               md5
      host  all all 172.28.0.0/16         md5
      host  all all fd00:7fd7:e9a5::/48   md5
    '';
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/srv/backups";
    startAt = "*-*-* 02:16:23 UTC";
  };
}
