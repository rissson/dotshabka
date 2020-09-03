{ config, lib, pkgs, ... }:

with lib;

let
  openldapStateDir = "/persist/openldap";
in {
  services.openldap = {
    enable = true;
    dataDir = "${openldapStateDir}/db";
    configDir = "${openldapStateDir}/slapd.d";
    urlList = [ "ldap:///" "ldapi:///" ];
  };

  environment.etc = mkIf config.services.openldap.enable {
    "openldap/slapd.conf" = {
      source = pkgs.substituteAll {
        src = ./slapd.conf;

        coreSchema = "${pkgs.openldap}/etc/schema/core.schema";
        cosineSchema = "${pkgs.openldap}/etc/schema/cosine.schema";
        inetorgpersonSchema = "${pkgs.openldap}/etc/schema/inetorgperson.schema";
        nisSchema = "${pkgs.openldap}/etc/schema/nis.schema";
        miscSchema = "${pkgs.openldap}/etc/schema/misc.schema";

        suffix = "dc=lama-corp,dc=space";
        dataDir = config.services.openldap.dataDir;
        rootPw = "{CRYPT}$6$$eFsJgRkgYWTpEx/WNOE3I1YX8tAoSUYlw9IWlrN6sXD1TJNib/cGghREKE11SXCE/M3RytQCtz18D5lr7Gt5r1";
      };
    };
  };

  systemd.services.openldap-backup = mkIf config.services.openldap.enable {
    description = "OpenLDAP backup";
    after = [ "openldap.service" ];
    startAt = "";
    serviceConfig.ExecStart = ''
      ${pkgs.openldap}/bin/slapcat -F ${config.services.openldap.configDir} -l ${openldapStateDir}/openldap_backup.ldif
    '';
  };
}
