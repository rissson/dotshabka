{ mode, config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.soxin.programs.neovim.enable {
    soxin.programs.neovim = {
      extraConfig = builtins.concatStringsSep "\n" [
        (pkgs.callPackage ./customrc.nix { })
      ];

      plugins = with pkgs.vimPlugins; [
        vim-gist
        gundo-vim
        LanguageClient-neovim
        PreserveNoEOL
        ack-vim
        ale
        auto-pairs
        caw
        csv-vim
        deoplete-go
        deoplete-nvim
        direnv-vim
        easy-align
        easymotion
        editorconfig-vim
        emmet-vim
        fzf-vim
        fzfWrapper
        goyo
        multiple-cursors
        ncm2
        pig-vim
        repeat
        rhubarb
        sleuth
        surround
        traces-vim
        vim-airline
        vim-airline-themes
        vim-better-whitespace
        vim-clang-format
        vim-eunuch
        vim-fugitive
        vim-go
        vim-markdown
        vim-scala
        vim-signify
        vim-speeddating
        vim-terraform
        vimtex
        vissort-vim
        webapi-vim # required for vim-gist
        yats-vim
        zoomwintab-vim

        # NOTE: polyglot must be loaded manually because if it gets loaded
        # before vim-go and conflicts with it causing problems starting nvim.
        # See https://github.com/sheerun/vim-polyglot/issues/309
        { plugin = polyglot; optional = true; }
      ];
    };
  };
}
