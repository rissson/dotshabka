# Packages in this list are imported by hosts/default.nix, and are pulled from
# nixpkgs master instead of the default nixos release. This doesn't actually
# install them, just creates an overlay to pull them from master if they are
# installed by the user elsewhere in the configuration.
{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    awscli
    bird-lg-go-frontend
    bird-lg-go-proxy
    claws-mail
    chromium
    discord
    element-desktop
    ferdi
    mr
    netdata
    nixpkgs-fmt
    nixpkgs-review
    s3cmd
    slack
    spotify
    steam
    teams
    thunderbird
    tmuxp
    vlc
    warsow
  ;
  inherit (pkgsMaster)
    firefox
  ;
}
