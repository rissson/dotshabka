let
  defaultDeployment = { config }: {
    secrets = {
      "borg/system.ssh.key" = {
        source = "../secrets/hosts/${config.networking.hostName}/borg/system.ssh.key";
        destination = "/srv/secrets/borg/system.ssh.key";
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
      };
    };
  };
in {
  network = { description = "Lama Corp. servers"; };

  "minio-1.vrt.fsn" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/minio-1/configuration.nix" ];
  };

  "postgres-1.vrt.fsn" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/postgres-1/configuration.nix" ];
  };
}
