{ userName, lib, ... }:

{
  config = lib.mkMerge [
    {
      krb5 = {
        enable = true;
        libdefaults = {
          default_realm = "LAMA-CORP.SPACE";
          dns_fallback = true;
          dns_canonicalize_hostname = false;
          rnds = false;
        };

        realms = {
          "LAMA-CORP.SPACE" = {
            admin_server = "kerberos.lama-corp.space";
          };
        };
      };
    }

    (lib.optionalAttrs (userName == "risson") {
      krb5 = {
        realms = {
          "CRI.EPITA.FR" = {
            admin_server = "kerberos.pie.cri.epita.fr";
          };
        };
      };
    })
  ];
}
