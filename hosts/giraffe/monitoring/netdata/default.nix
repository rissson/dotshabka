{ config, lib, pkgs, ... }:

with lib;

{
  environment.etc = mkIf config.services.netdata.enable {
    "netdata/go.d.conf".text = ''
      modules:
        httpcheck: yes
    '';
    "netdata/go.d/httpcheck.conf".text =
      builtins.readFile ./go.d/httpcheck.conf;
    "netdata/go.d/portcheck.conf".text =
      builtins.readFile ./go.d/portcheck.conf;
    "netdata/go.d/x509check.conf".text =
      builtins.readFile ./go.d/x509check.conf;

    "netdata/python.d.conf".text = ''
      example: no
      httpcheck: no
      logind: yes
    '';
  };
}
