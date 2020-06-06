let
  defaultDeployment = { config }: {
    targetUser = "root";
  };
in with import <dotshabka/data/space.lama-corp> {}; {
  network = { description = "Lama Corp. bar machines"; };

  "cuckoo.mmd.bar.lama-corp.space" = { config, ... }: {
    deployment = defaultDeployment { inherit config; };

    imports = [ "${<dotshabka>}/hosts/cuckoo/configuration.nix" ];
  };
}
