# Packages in this list are imported by hosts/default.nix, and are pulled from
# nixpkgs master instead of the default nixos release. This doesn't actually
# install them, just creates an overlay to pull them from master if they are
# installed by the user elsewhere in the configuration.
pkgsMaster:

final: prev: {
  inherit (pkgsMaster)
    awscli
    bird-lg-go-frontend
    bird-lg-go-proxy
    claws-mail
    discord
    element-desktop
    mr
    nixpkgs-fmt
    nixpkgs-review
    rambox
    s3cmd
    slack
    spotify
    teams
    thunderbird
    tmuxp
    vlc
    warsow
  ;
}
