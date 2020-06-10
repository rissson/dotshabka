{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.ldap;

  stateDir = "/srv/ldap";
in {
  options = {
    lama-corp.ldap = {
      enable = mkEnableOption "Enable LDAP server";
      stateDir = mkOption {
        type = types.str;
        default = "/srv/ldap";
      };
    };
  };

  config = mkIf cfg.enable {
    services.openldap = {
      enable = true;
      dataDir = "${cfg.stateDir}/db";
      configDir = "${cfg.stateDir}/slapd.d";
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

    ###
    # Backups
    ###

    services.borgbackup.jobs."system" = mkIf config.lama-corp.common.backups.enable {
      preHook = concatStrings [
        (optionalString config.services.openldap.enable ''
          ${pkgs.openldap}/bin/slapcat -F ${config.services.openldap.configDir} -l ${cfg.stateDir}/ldap_backup.ldif
        '')
      ];

      readWritePaths = [ cfg.stateDir ];
    };
  };
}
