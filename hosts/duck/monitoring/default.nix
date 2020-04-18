{ config, lib, ... }:

with lib;

{
  services.netdata = {
    enable = true;
  };

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/python.d.conf".text = builtins.readFile ./python.d.conf;
    "netdata/python.d/nginx.conf".text = builtins.readFile ./python.d/nginx.conf;
    "netdata/python.d/web_log.conf".text = builtins.readFile ./python.d/web_log.conf;
  };
}
