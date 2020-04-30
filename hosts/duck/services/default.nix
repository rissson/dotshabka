{ ... }:

{
  imports = [
    ./databases.nix
    ./gitlab-runners
    ./hercules-ci.nix
    ./libvirt
    ./mattermost
    ./s3.nix
    ./TheFractalBot.nix
    ./web
  ];
}
