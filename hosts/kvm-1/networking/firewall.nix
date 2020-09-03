{ ... }:

with import <dotshabka/data/space.lama-corp/fsn/srv/kvm-1> { }; {
  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPortRanges = [
      {
        # weechat
        from = 8000;
        to = 8100;
      }
      {
        # aria2c
        from = 6881;
        to = 6999;
      }
    ];
    allowedUDPPortRanges = [
      {
        # mosh
        from = 60000;
        to = 61000;
      }
      {
        # aria2c
        from = 6881;
        to = 6999;
      }
    ];

    interfaces = {
      "ve-+" = {
        allowedTCPPorts = [
          53 # DNS
        ];
        allowedUDPPorts = [
          53 # DNS
        ];
      };
      "${internal.interface}" = {
        allowedTCPPorts = [
          53 # DNS
          19999 # Netdata
        ];
        allowedUDPPorts = [
          53 # DNS
        ];
      };
      "${wg.interface}" = {
        allowedTCPPorts = [
          53 # DNS
          19999 # Netdata
        ];
        allowedUDPPorts = [
          53 # DNS
        ];
      };
    };
  };
}
