{ ... }:

{
  /* preHook = concatStrings [
       (optionalString config.services.openldap.enable ''
         ${pkgs.openldap}/bin/slapcat -F ${config.services.openldap.configDir} -l /srv/backups/ldap_backup.ldif
       '')
     ];

     readWritePaths = [
       "/srv/backups"
       "/srv/ldap"
     ];
  */

  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc -v";
    frequent = 4;
    hourly = 24;
    daily = 7;
    weekly = 4;
    monthly = 12;
  };
}
