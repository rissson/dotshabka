{ pkgs, ... }:

with pkgs;

{
  home.packages = [
    amazon-ecr-credential-helper
    docker-credential-gcr

    browsh

    gist

    gnupg

    go

    jq

    jrnl

    killall

    lastpass-cli

    mercurial

    mosh

    nur.repos.kalbasit.nixify

    nix-index

    nixops

    # curses-based file manager
    lf

    unzip

    nix-zsh-completions
  ] ++ (if stdenv.isLinux then [
    #
    # Linux applications
    #

    # XXX: Failing to compile on Darwin
    gotop

    jetbrains.idea-community

    keybase

    slack

    # Games
    _2048-in-terminal
  ] else if stdenv.isDarwin then [
    #
    # Mac-only applications
    #

  ] else []);

  programs.bat.enable = true;
  programs.direnv.enable = true;
}
