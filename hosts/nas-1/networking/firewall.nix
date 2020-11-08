{ ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [
      22 # ssh
      53 # dns
      67 # dhcp
    ];

    allowedUDPPorts = [
      53 # dns
      67 # dhcp
    ];

    interfaces = {
      wg0 = {
        allowedTCPPorts = [
          19999 # Netdata
        ];
      };
      wg1 = {
        allowedTCPPorts = [
          19999 # Netdata
        ];
      };
    };
  };
}
