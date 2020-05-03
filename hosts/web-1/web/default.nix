{ pkgs, ... }:

{
  disabledModules = [ "services/web-servers/uwsgi.nix" ];

  imports = [
    ./acdc.risson.space.nix
    ./beauflard.risson.space.nix
    ./cats.acdc.risson.space.nix
    ./jdmi.risson.space.nix
    ./lama-corp.space.nix
    ./risson.space.nix

    ./uwsgi.nix
  ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;

    commonHttpConfig = ''
      access_log off;
    '';

    statusPage = true;
  };

  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance = { type = "emperor"; };
  };
}
