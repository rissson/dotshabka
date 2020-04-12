{ ... }:

{
  imports = [
    ./databases.nix
    ./hercules-ci.nix
    ./s3.nix
    ./TheFractalBot.nix
    ./web
  ];
}
