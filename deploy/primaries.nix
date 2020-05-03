let
  defaultDeployment = { config, wg }: {
    targetUser = "root";
    secrets = {
      "ssmtp-root_lama-corp_ovh_passwd" = {
        source = "../secrets/files/ssmtp/root_lama-corp_ovh.passwd";
        destination = config.services.ssmtp.authPassFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0444";
      };
      "wireguard/private.key" = {
        source = "../secrets/files/hosts/${config.networking.hostName}/wireguard/private.key";
        destination = config.networking.wireguard.interfaces.${wg.interface}.privateKeyFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0400";
      };
    };
  };
in with import <dotshabka/data/space.lama-corp> {}; {
  network = { description = "Lama Corp. primary servers"; };

  "duck.srv.fsn.lama-corp.space" = with fsn.srv.duck; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; };

    assertions = [
      {
        assertion = !config.services.nginx.enable;
        message = "If nginx is enabled on duck, it means that this deployment is not reproducible";
      }
    ];

    imports = [ "${<dotshabka>}/hosts/duck/configuration.nix" ];
  };

  "giraffe.srv.nbg.lama-corp.space" = with nbg.srv.giraffe; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; } // {
      secrets = {
        "borg/nas-system.ssh.key" = {
          source = "../secrets/files/hosts/${config.networking.hostName}/borg/nas-system.ssh.key";
          destination = "/srv/secrets/borg/nas-system.ssh.key";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
        };
      };
    };

    imports = [ "${<dotshabka>}/hosts/giraffe/configuration.nix" ];
  };

  "nas.srv.bar.lama-corp.space" = with bar.srv.nas; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; };

    imports = [ "${<dotshabka>}/hosts/nas/configuration.nix" ];
  };
}
