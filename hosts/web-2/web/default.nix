{ pkgs, ... }:

{
  disabledModules = [ "services/web-servers/uwsgi.nix" ];

  imports = [
    ./cats.acdc.risson.space.nix
    ./scoreboard-seedbox-cri.risson.space.nix

    ./uwsgi.nix
  ];

  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance.type = "emperor";
  };
}
