{ pkgs, ... }:

{
  imports = [
    ./acdc.risson.space.nix
    ./beauflard.risson.space.nix
    ./bin.lama-corp.space.nix
    ./jdmi.risson.space.nix
    ./lama-corp.space.nix
    ./risson.space.nix
  ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;

    commonHttpConfig = ''
      access_log off;
    '';

    statusPage = true;
  };
}
