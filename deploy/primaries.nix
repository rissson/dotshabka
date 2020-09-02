let
  defaultDeployment = { config, wg }: {
    targetUser = "root";
    secrets = {
      "wireguard/private.key" = {
        source = "../secrets/hosts/${config.networking.hostName}/wireguard/private.key";
        destination = config.networking.wireguard.interfaces.${wg.interface}.privateKeyFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
      };
    };
  };
in with import <dotshabka/data/space.lama-corp> {}; {
  network = { description = "Lama Corp. primary servers"; };

  "kvm-1.srv.fsn" = with fsn.srv.kvm-1; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; };

    imports = [ "${<dotshabka>}/hosts/kvm-1/configuration.nix" ];
  };

  "giraffe.srv.nbg" = with nbg.srv.giraffe; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; } // {
      secrets = {
        "borg/system.ssh.key" = {
          source = "../secrets/hosts/${config.networking.hostName}/borg/system.ssh.key";
          destination = "/srv/secrets/borg/system.ssh.key";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
        };
        "grafana/database.passwd" = {
          source = "../secrets/hosts/${config.networking.hostName}/grafana/database.passwd";
          destination = "/srv/secrets/grafana/database.passwd";
          owner.user = "grafana";
          owner.group = "grafana";
          permissions = "0400";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/giraffe/configuration.nix" ];
  };

  "nas.srv.bar" = with bar.srv.nas; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; };

    imports = [ "${<dotshabka>}/hosts/nas/configuration.nix" ];
  };
}
