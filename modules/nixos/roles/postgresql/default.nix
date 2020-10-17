{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.postgresql;
in {
  options = {
    lama-corp.postgresql = {
      enable = mkEnableOption "Enable postgresql";
      stateDir = mkOption {
        type = types.str;
        default = "/srv/postgresql";
      };
      ensureDatabasesAndUsers = mkOption {
        type = with types; listOf str;
        default = [];
      };
      # TODO: allowedNetworks
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_11;
      enableTCPIP = true;
      dataDir = "${cfg.stateDir}/11";
      authentication = ''
        local all all                       ident
        host  all all 127.0.0.1/32          md5
        host  all all ::1/128               md5
        host  all all 172.28.0.0/16         md5
        host  all all 10.231.0.0/16         md5
        host  all all fd00:7fd7:e9a5::/48   md5
      '';
      ensureDatabases = cfg.ensureDatabasesAndUsers;
      ensureUsers = map (v: { name = v; ensurePermissions = { "DATABASE ${v}" = "ALL PRIVILEGES"; }; }) cfg.ensureDatabasesAndUsers;
    };

    services.postgresqlBackup = mkIf config.lama-corp.common.backups.enable {
      enable = true;
      backupAll = true;
      location = cfg.stateDir;
      startAt = "daily";
    };
  };
}
