{ config, pkgs, lib, ... }:

with lib;

{
  config = {

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

      format = {
        signOff = true;
      };

      push = {
        default = "simple";
      };

      pull = {
        rebase = true;
      };
    };

   programs.git.includes = [
     {
       condition = "gitdir:~/cri/";
       contents = {
         user = {
           email = "risson@cri.epita.fr";
           signingkey = "risson@cri.epita.fr";
         };
       };
     }
     {
       condition = "gitdir:~/prologin/";
       contents = {
         user = {
           email = "marc.schmitt@prologin.org";
           signingkey = "marc.schmitt@prologin.org";
         };
       };
     }
     {
       condition = "gitdir:~/lama-corp/";
       contents = {
         user = {
           email = "marc.schmitt@lama-corp.space";
           signingkey = "marc.schmitt@lama-corp.space";
         };
       };
     }
   ];
  };
}
