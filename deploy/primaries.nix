let
  defaultDeployment = { config, wg }: {
    targetUser = "root";
    secrets = {
      "ssmtp-root_lama-corp_ovh_passwd" = {
        source = "../secrets/ssmtp/root_lama-corp_ovh.passwd";
        destination = config.services.ssmtp.authPassFile;
        owner.user = "root";
        owner.group = "root";
        permissions = "0444";
      };
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

  "kvm-1.srv.fsn.lama-corp.space" = with fsn.srv.kvm-1; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; };

    imports = [ "${<dotshabka>}/hosts/kvm-1/configuration.nix" ];
  };

  "giraffe.srv.nbg.lama-corp.space" = with nbg.srv.giraffe; { config, ... }: {
    deployment = defaultDeployment { inherit config wg; } // {
      secrets = {
        "borg/nas-system.ssh.key" = {
          source = "../secrets/hosts/${config.networking.hostName}/borg/nas-system.ssh.key";
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
