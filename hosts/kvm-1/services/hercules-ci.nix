{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    (builtins.fetchTarball
      "https://github.com/hercules-ci/hercules-ci-agent/archive/stable.tar.gz"
      + "/module.nix")
  ];

  services.hercules-ci-agent = {
    enable = true;
    concurrentTasks = 4;
    patchNix = true;
  };

  nix = {
    binaryCaches = [
      "http://hercules-ci.cachix.org"
    ];
    binaryCachePublicKeys = [
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
    ];
  };
}
