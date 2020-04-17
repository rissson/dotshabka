{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_11;
    dataDir = "/srv/postgresql/11";
    ensureDatabases = [
      "catcdc"
      "codimd"
      "pastebin"
      "scoreboard-seedbox-cri"
    ];
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
        ensurepermissions = { "DATABASE pastebin" = "ALL PRIVILEGES"; };
      }
      {
        name = "scoreboard-seedbox-cri";
        ensurepermissions = { "DATABASE scoreboard-seedbox-cri" = "ALL PRIVILEGES"; };
      }
    ];
  };
}
