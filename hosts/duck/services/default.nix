{ ... }:

{
  imports = [
    ./databases.nix
    ./hercules-ci.nix
    ./libvirt
    ./s3.nix
    ./TheFractalBot.nix
    ./web
  ];
}
