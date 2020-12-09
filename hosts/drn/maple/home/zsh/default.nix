{ config, pkgs, lib, ... }:

with pkgs;
with lib;
{
  #imports = [ ./secrets.nix ];

  programs.zsh = {
    enable = true;
    autocd = true;

    shellAliases = {
      cat = "bat";
      r = "ranger";
      py = "ptpython";
      bri = "brightnessctl";
      vim = "nvim";
      vi = "nvim";
      hm = "cd ~/prog/nixos-conf/home && vim && cd -";
      mana = "home-manager switch -f ~/prog/nixos-conf/home.nix";  # -I nixpkgs=/home/diego/prog/nixpkgs";
      deadd = "kill -USR1 $(pidof deadd-notification-center)";
      rm = "rm -I";
      hue = "hue.py";
      cdmooc = "cd ~/epfl/ass-poo/cpp-java-assignments/intro-cpp/";
      nix-zsh = "nix-shell --run zsh";
    };

    sessionVariables = {

    };

    history = {
      size = 100000;
      save = 100000;
      expireDuplicatesFirst = true;
    };

    oh-my-zsh = {
      enable = true;

      plugins = [
        "command-not-found"
        "git"
        "history"
        "sudo"
      ];
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
          sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
        };
      }
      {
        name = "zsh-completions";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.27.0";
          sha256 = "1c2xx9bkkvyy0c6aq9vv3fjw7snlm0m5bjygfk5391qgjpvchd29";
        };
      }
      {
        name = "zsh-history-substring-search";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "47a7d416c652a109f6e8856081abc042b50125f4";
          sha256 = "1mvilqivq0qlsvx2rqn6xkxyf9yf4wj8r85qrxizkf0biyzyy4hl";
       };
       }

    ];

    initExtra = (builtins.readFile (substituteAll {
      src = ./init-extra.zsh;

      bat_bin      = "${getBin bat}/bin/bat";
      home_path    = "${config.home.homeDirectory}";
      less_bin     = "${getBin less}/bin/less";
     }));
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}

