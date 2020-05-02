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
}
