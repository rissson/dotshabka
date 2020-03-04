{ config, pkgs, lib, ... }:

with lib;

{
  shabka.git = {
    userName = "Marc 'risson' Schmitt";
    userEmail = "marc.schmitt@risson.space";
    gpgSigningKey = "marc.schmitt@risson.space";
  };

  programs.git.package = mkForce pkgs.gitAndTools.gitFull;
  programs.git.aliases = {
    b         = "branch";
    coke      = "commit -a -m";
    cokewogpg = "commit --no-gpg-sign -a -m";
  };

  programs.git.extraConfig = {

    branch = {
      autosetuprebase = "always";
    };

    core = {
      editor = "vim";
    };

    push = {
      default = "simple";
    };

    pull = {
      rebase = true;
    };
  };

  includes = [
    {
      condition = "gitdir:~/cri/";
      contents = {
        user = {
          email = "risson@cri.epita.fr";
          signingkey = "risson@cri.epita.fr";
        };
      };
    }
  ];
}
