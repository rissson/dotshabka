{ pkgs, ... }:

with pkgs;

{
  home.packages = [];

  programs.command-not-found.enable = true;
}
