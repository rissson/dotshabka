{ ... }:

{
  imports = [
    ./databases.nix
    ./gitlab-runners
    ./hercules-ci.nix
    ./ldap
    ./libvirt
    ./mail
    ./mattermost
    ./s3.nix
    ./TheFractalBot.nix
    ./web
  ];
}
