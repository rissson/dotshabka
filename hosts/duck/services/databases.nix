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
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/srv/mysql";
    ensureDatabases = [
      "yourls"
    ];
    ensureUsers = [
      {
        name = "yourls";
        ensurePermissions = { "yourls.*" = "ALL PRIVILEGES"; };
      }
    ];
  };
}
