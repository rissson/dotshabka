{ pkgs, ... }:

{
  disabledModules = [ "services/web-servers/uwsgi.nix" ];

  imports = [
    ./uwsgi.nix
  ];

  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance = { type = "emperor"; };
  };
}
