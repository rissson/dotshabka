{ pkgs, ... }:

{
  imports = [
    ./acdc.risson.space.nix
  ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;

    statusPage = true;
  };
}
