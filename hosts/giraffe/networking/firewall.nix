{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { }; {
  networking = with nbg.srv.giraffe; {
    firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [
        51820 # wireguard
      ];

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];

      interfaces = {
        "${wg.interface}" = {
          allowedTCPPorts = [
            3000 # Grafana
            19999 # Netdata
            20042 # influxdb
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [{
            from = 60000;
            to = 61000;
          } # mosh
            ];
        };
      };
    };
  };
}
