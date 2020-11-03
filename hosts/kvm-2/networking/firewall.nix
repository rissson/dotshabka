{ ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedUDPPortRanges = [
      {
        # mosh
        from = 60000;
        to = 61000;
      }
    ];

    interfaces = {
      "br-k8s" = {
        allowedTCPPorts = [
          53 # DNS
        ];
        allowedUDPPorts = [
          53 # DNS
        ];
      };
      "wg0" = {
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
