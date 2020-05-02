{ config, pkgs, lib, ... }:

with lib;

{
  services.openldap = {
    enable = true;
    dataDir = "/srv/ldap/db";
    configDir = "/srv/ldap/slapd.d";
    urlList = [ "ldap:///" "ldapi:///" ];
  };

  environment.etc = mkIf config.services.openldap.enable {
    "openldap/slapd.conf" = {
      source = pkgs.substituteAll {
        src = ./slapd.conf;

        coreSchema = "${pkgs.openldap}/etc/schema/core.schema";
        cosineSchema = "${pkgs.openldap}/etc/schema/cosine.schema";
        inetorgpersonSchema =
          "${pkgs.openldap}/etc/schema/inetorgperson.schema";
        nisSchema = "${pkgs.openldap}/etc/schema/nis.schema";
        miscSchema = "${pkgs.openldap}/etc/schema/misc.schema";

        suffix = "dc=lama-corp,dc=space";
        dataDir = config.services.openldap.dataDir;
        rootPw =
          "{CRYPT}$6$$eFsJgRkgYWTpEx/WNOE3I1YX8tAoSUYlw9IWlrN6sXD1TJNib/cGghREKE11SXCE/M3RytQCtz18D5lr7Gt5r1";
      };
    };
  };
}
