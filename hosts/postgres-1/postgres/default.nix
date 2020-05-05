{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    enableTCPIP = true;
    authentication = ''
      local all all                       ident
      host  all all 127.0.0.1/32          md5
      host  all all ::1/128               md5
      host  all all 172.28.0.0/16         md5
      host  all all fd00:7fd7:e9a5::/48   md5
    '';
    dataDir = "/srv/postgresql/11";
    ensureDatabases = [ "catcdc" "codimd" "pastebin" "scoreboard_seedbox_cri" ];
    ensureUsers = [
      {
        name = "catcdc";
        ensurePermissions = { "DATABASE catcdc" = "ALL PRIVILEGES"; };
      }
      {
        name = "codimd";
        ensurePermissions = { "DATABASE codimd" = "ALL PRIVILEGES"; };
      }
      {
        name = "pastebin";
        ensurePermissions = { "DATABASE pastebin" = "ALL PRIVILEGES"; };
      }
      {
        name = "scoreboard_seedbox_cri";
        ensurePermissions = {
          "DATABASE scoreboard_seedbox_cri" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/srv/backups";
    startAt = "*-*-* 02:16:23 UTC";
  };
}
