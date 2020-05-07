let
  defaultDeployment = { config }: {
    secrets = {
      "ssmtp-root_lama-corp_ovh_passwd" = {
        source = "../secrets/ssmtp/root_lama-corp_ovh.passwd";
        destination = config.services.ssmtp.authPassFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0444";
      };
      "borg/nas-system.ssh.key" = {
        source = "../secrets/hosts/${config.networking.hostName}/borg/nas-system.ssh.key";
        destination = "/srv/secrets/borg/nas-system.ssh.key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
      };
    };
  };
in {
  network = { description = "Lama Corp. servers"; };

  "acdc-tp14-1.vrt.fsn.lama-corp.space" = { config, lib, ... }: {
    deployment = lib.mkMerge [ (defaultDeployment { inherit config; }) {
      secrets = {
        "tp14/tp14.ssh.key" = {
          source = "../secrets/hosts/acdc-tp14-1/tp14/tp14.ssh.key";
          destination = "/srv/secrets/tp14/tp14.ssh.key";
        };
        "tp14/tp14.ssh.pub" = {
          source = "../secrets/hosts/acdc-tp14-1/tp14/tp14.ssh.pub";
          destination = "/srv/secrets/tp14/tp14.ssh.pub";
        };
        "tp14/api.key" = {
          source = "../secrets/hosts/acdc-tp14-1/tp14/api.key";
          destination = "/srv/secrets/tp14/api.key";
        };
        "tp14/s3_access.key" = {
          source = "../secrets/hosts/acdc-tp14-1/tp14/s3_access.key";
          destination = "/srv/secrets/tp14/s3_access.key";
        };
        "tp14/s3_secret.key" = {
          source = "../secrets/hosts/acdc-tp14-1/tp14/s3_secret.key";
          destination = "/srv/secrets/tp14/s3_secret.key";
        };
      };
    }];

    imports = [ "${<dotshabka>}/hosts/acdc-tp14-1/configuration.nix" ];
  };

  "ldap-1.vrt.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/ldap-1/configuration.nix" ];
  };

  "mail-1.vrt.fsn.lama-corp.space" = { config, lib, ... }: {
    deployment = lib.mkMerge [ (defaultDeployment { inherit config; }) {
      secrets = {
        "acme/dns-credentials" = {
          source = "../secrets/acme/dns-credentials";
          destination = "/srv/secrets/acme/dns-credentials";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
      };
    }];

    imports = [ "${<dotshabka>}/hosts/mail-1/configuration.nix" ];
  };

  "minio-1.vrt.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/minio-1/configuration.nix" ];
  };

  "postgres-1.vrt.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/postgres-1/configuration.nix" ];
  };

  "reverse-1.vrt.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/reverse-1/configuration.nix" ];
  };

  "web-1.vrt.fsn.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/web-1/configuration.nix" ];
  };

  "web-2.vrt.fsn.lama-corp.space" = { config, lib, ... }: {
    deployment = lib.mkMerge [ (defaultDeployment { inherit config; }) {
      secrets = {
        "uwsgi/cats.acdc.risson.space.settings.py" = {
          source = "../secrets/hosts/web-2/uwsgi/cats.acdc.risson.space.settings.py";
          destination = "/srv/secrets/uwsgi/cats.acdc.risson.space.settings.py";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
        "uwsgi/scoreboard-seedbox-cri.risson.space.settings.py" = {
          source = "../secrets/hosts/web-2/uwsgi/scoreboard-seedbox-cri.risson.space.settings.py";
          destination = "/srv/secrets/uwsgi/scoreboard-seedbox-cri.risson.space.settings.py";
          owner.user = "root";
          owner.group = "root";
          permissions = "0444";
        };
      };
    }];

    imports = [ "${<dotshabka>}/hosts/web-2/configuration.nix" ];
  };
}
