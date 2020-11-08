{ ... }:

{
  networking.firewall.interfaces."br-k8s" = {
    allowedTCPPorts = [ 111 2049 ];
    allowedUDPPorts = [ 111 2049 ];
  };

  services.nfs.server = {
    enable = true;
  };
}
