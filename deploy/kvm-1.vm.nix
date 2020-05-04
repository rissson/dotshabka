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
      "borg/nas-system.ssh.key" = {
        source = "../secrets/files/hosts/${config.networking.hostName}/borg/nas-system.ssh.key";
        destination = "/srv/secrets/borg/nas-system.ssh.key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
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
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "acme/dns-credentials" = {
          source = "../secrets/files/acme/dns-credentials";
          destination = "/srv/secrets/acme/dns-credentials";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/mail-1/configuration.nix" ];
  };

  "postgres-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/postgres-1/configuration.nix" ];
  };

  "reverse-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/reverse-1/configuration.nix" ];
  };

  "web-1.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "uwsgi/cats.acdc.risson.space" = {
          source = "../secrets/files/hosts/web-1/uwsgi/cats.acdc.risson.space.settings.py";
          destination = "/srv/secrets/uwsgi/cats.acdc.risson.space.settings.py";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/web-1/configuration.nix" ];
  };

  "web-2.duck.srv.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; } // {
      secrets = {
        "uwsgi/cats.acdc.risson.space.settings.py" = {
          source = "../secrets/files/hosts/web-2/uwsgi/cats.acdc.risson.space.settings.py";
          destination = "/srv/secrets/uwsgi/cats.acdc.risson.space.settings.py";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
        "uwsgi/scoreboard-seedbox-cri.risson.space.settings.py" = {
          source = "../secrets/files/hosts/web-2/uwsgi/scoreboard-seedbox-cri.risson.space.settings.py";
          destination = "/srv/secrets/uwsgi/scoreboard-seedbox-cri.risson.space.settings.py";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/web-2/configuration.nix" ];
  };
}
