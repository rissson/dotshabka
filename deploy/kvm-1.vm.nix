let
  defaultDeployment = { config }: {
    secrets = {
      "ssmtp-root_lama-corp_ovh_passwd" = {
        source = "../secrets/files/ssmtp/root_lama-corp_ovh.passwd";
        destination = config.services.ssmtp.authPassFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0444";
      };
    };
  };
in {
  network = { description = "Lama Corp. servers"; };

  "ldap-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "borg/nas-system.ssh.key" = {
          source = "../secrets/files/hosts/ldap-1/borg/nas-system.ssh.key";
          destination = "/srv/secrets/borg/nas-system.ssh.key";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/ldap-1/configuration.nix" ];
  };

  "mail-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "acme/dns-credentials" = {
          source = "../secrets/files/acme/dns-credentials";
          destination = "/srv/secrets/acme/dns-credentials";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
        "borg/nas-system.ssh.key" = {
          source = "../secrets/files/hosts/mail-1/borg/nas-system.ssh.key";
          destination = "/srv/secrets/borg/nas-system.ssh.key";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/mail-1/configuration.nix" ];
  };

  "reverse-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "borg/nas-system.ssh.key" = {
          source = "../secrets/files/hosts/reverse-1/borg/nas-system.ssh.key";
          destination = "/srv/secrets/borg/nas-system.ssh.key";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/reverse-1/configuration.nix" ];
  };
}
