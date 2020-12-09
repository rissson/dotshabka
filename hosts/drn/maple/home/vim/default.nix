{ pkgs, ... }:

let
  vim-monokai = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-monokai";
    version = "2020-06-02";
    src = pkgs.fetchFromGitHub {
      owner = "sickill";
      repo = "vim-monokai";
      rev = "c90ab87be51d347b3ff15f3273affc4d373cf56a";
      sha256 = "1gd7adjczphaf52bqk1mdi811xvq5cip8g2v7dir414fhf14p741";
    };
    meta.homepage = "https://github.com/sickill/vim-monokai";
  };

  vim-workspace = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-workspace";
    version = "2020-06-02";
    src = pkgs.fetchFromGitHub {
      owner = "thaerkh";
      repo = "vim-workspace";
      rev = "faa835406990171bbbeff9254303dad49bad17cb";
      sha256 = "0lzba39sb4yxla3vr4rmxg342f61sfvf4ygwf8ahb5r9q8arr863";
    };
  };

  confortable-motion-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "confortable-motion-vim";
    version = "2020-06-02";
    src = pkgs.fetchFromGitHub {
      owner = "yuttie";
      repo = "comfortable-motion.vim";
      rev = "e20aeafb07c6184727b29f7674530150f7ab2036";
      sha256 = "13chwy7laxh30464xmdzjhzfcmlcfzy11i8g4a4r11m1cigcjljb";
    };
  };

  vim-indentguides = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-indentguides";
    version = "2020-06-02";
    src = pkgs.fetchFromGitHub {
      owner = "thaerkh";
      repo = "vim-indentguides";
      rev = "359f35ec0a0febd1466d5d12de31d104f1838a6f";
      sha256 = "0bngzlwbjxyjd54zmp8059jmdgd6kx3qy8gzxib0y7b1yca6lwzb";
    };
  };

  vim-markdown-gabrielelana = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-markdown";
    version = "2020-06-05";
    src = pkgs.fetchFromGitHub {
      owner = "gabrielelana";
      repo = "vim-markdown";
      rev = "772de97c97d37e5e22d7bd6884b17b858a687bc2";
      sha256 = "sha256:173y0wglpgcxbkgwg5vhbd4hqn6g2ad8lf50qm925rqpxhqrv1rk";
    };
  };

  vim-matlab = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-matlab";
    version = "2020-07-01";
    src = pkgs.fetchFromGitHub {
      owner = "daeyun";
      repo = "vim-matlab";
      rev = "eafe639be77454b6bf46f149a7695de773b702b9";
      sha256 = "sha256:0lc54bghrr5gwbf54wi5irgjjnqrr9s69ywiv4pw44vr18hqyf6c";
    };
  };

in {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    configure = {
      customRC = builtins.readFile ./vimrc;

      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [
          vim-airline
          nerdtree
          vim-indentguides

          vim-nix
          vim-airline-themes
          vim-monokai
          rainbow
          confortable-motion-vim

          vimtex

          deoplete-nvim
          # deoplete-clang
          deoplete-jedi
          jedi-vim
          # python-mode
          vim-commentary
          vim-workspace
          ultisnips
          vim-snippets

          vim-markdown-gabrielelana
          auto-pairs


        ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [
          vim-wakatime
        ];
      };
    };
  };

  home.packages = with pkgs; [
    neovim-remote
  ];
}
