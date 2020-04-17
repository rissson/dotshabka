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
      "scoreboard_seedbox_cri"
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
        ensurePermissions = { "DATABASE pastebin" = "ALL PRIVILEGES"; };
      }
      {
        name = "scoreboard_seedbox_cri";
        ensurePermissions = { "DATABASE scoreboard_seedbox_cri" = "ALL PRIVILEGES"; };
      }
    ];
  };
}
