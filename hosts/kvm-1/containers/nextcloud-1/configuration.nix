{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud18;
    home = "/persist/nextcloud";
    hostName = "cloud.lama-corp.space";
    https = true;
    config = {
      adminuser = "root";
      adminpassFile = "/persist/nextcloud.admin.pass";
      dbtype = "pgsql";
      dbhost = "postgres-1.vrt.fsn.lama-corp.space";
      dbport = 5432;
      dbuser = "nextcloud";
      dbname = "nextcloud";
      dbpassFile = "/persist/nextcloud.db.pass";
      overwriteProtocol = "https";
    };
    maxUploadSize = "1024M";
    nginx.enable = true;
  };
}
