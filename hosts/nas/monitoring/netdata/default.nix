{ config, lib, pkgs, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/python.d.conf".text = ''
      logind: yes
    '';
  };
}
