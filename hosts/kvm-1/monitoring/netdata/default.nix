{ config, lib, pkgs, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d/unbound.conf".text = builtins.readFile ./go.d/unbound.conf;

    "netdata/python.d.conf".text = ''
      example: no
      logind: yes
    '';
  };
}
