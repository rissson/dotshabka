{ ... }:

with import <dotshabka/data/space.lama-corp/fsn/srv/duck> { }; {
  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPortRanges = [
      {
        from = 8000;
        to = 8100;
      } # weechat
      {
        from = 6881;
        to = 6999;
      } # aria2c
    ];
    allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      } # mosh
      {
        from = 6881;
        to = 6999;
      } # aria2c
    ];

    interfaces = {
      "${internal.interface}" = {
        allowedTCPPorts = [
          53 # DNS
          5432 # postgresql
          19000 # minio
        ];
        allowedUDPPorts = [
          53 # DNS
        ];

        allowedTCPPortRanges = [ ];
        allowedUDPPortRanges = [ ];
      };
      "${wg.interface}" = {
        allowedTCPPorts = [
          53 # DNS
          5432 # postgresql
          19000 # minio
          19999 # Netdata
        ];
        allowedUDPPorts = [
          53 # DNS
        ];

        allowedTCPPortRanges = [ ];
        allowedUDPPortRanges = [ ];
      };
    };
  };
}
