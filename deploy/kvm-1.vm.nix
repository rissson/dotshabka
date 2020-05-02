let
  defaultDeployment = { config }: {
    secrets = {
      "ssmtp-root_lama-corp_ovh_passwd" = {
        source = "../secrets/files/ssmtp/root_lama-corp_ovh.passwd";
        destination = config.services.ssmtp.authPassFile;
        owner = {
          user = "root";
          group = "root";
        };
        permissions = "0444";
      };
    };
  };
in {
  network = { description = "Lama Corp. servers"; };

  "ldap-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/ldap-1/configuration.nix" ];
  };

  "mail-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/mail-1/configuration.nix" ];
  };

  "reverse-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/reverse-1/configuration.nix" ];
  };
}
