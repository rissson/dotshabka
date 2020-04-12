{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    shabka.neovim = {
      extraRC = mkForce ''
        set background=dark
        colorscheme gruvbox
        let g:airline_theme='gruvbox'

        " set the mapleader
        let mapleader = " "
        " Whitespace
        set expandtab    " don't use tabs
        set shiftwidth=4 " Number of spaces to use for each step of (auto)indent.
        set softtabstop=8    " Number of spaces that a <Tab> in the file counts for.
        autocmd Filetype make setlocal noexpandtab " don't expand in makefiles

        set listchars=tab:»·              " a tab should display as "»·"
        set listchars+=trail:·            " show trailing spaces as dots
      '';
    };
  };
}
