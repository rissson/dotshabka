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
    authentication = ''
      # Generated file; do not edit!
      local all all              ident
      host  all all 127.0.0.1/32 md5
      host  all all ::1/128      md5
      hostnossl all all 172.28.1.11/32 trust
    '';
  };
}
