{ ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = true;

    interfaces = {
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
