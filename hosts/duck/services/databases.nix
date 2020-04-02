{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_11;
    dataDir = "/srv/postgresql/11";
    ensureDatabases = [ "catcdc" ];
    ensureUsers = [
      {
        name = "catcdc";
        ensurePermissions = { "DATABASE catcdc" = "ALL PRIVILEGES"; };
      }
    ];
  };
}
