{ ... }:

{
  imports = [
    ./databases.nix
    ./hercules-ci.nix
    ./libvirt
    ./mattermost
    ./s3.nix
    ./TheFractalBot.nix
    ./web
  ];
}
