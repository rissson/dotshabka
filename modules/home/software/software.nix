{ pkgs, ... }:

with pkgs;

let
  shabka = import <shabka> { };
in {
  home.packages = [

  ] ++ (if stdenv.isLinux then [
    #
    # Linux applications
    #

  ] else if stdenv.isDarwin then [
    #
    # Mac-only applications
    #

  ] else []);

  programs.command-not-found.enable = true;
}