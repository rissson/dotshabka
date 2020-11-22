{ ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = true;

    interfaces = {
      "br-vms" = {
        allowedTCPPorts = [
          53 # DNS
        ];
        allowedUDPPorts = [
          53 # DNS
        ];
      };

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
