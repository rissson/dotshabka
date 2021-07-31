{ ... }:

{
  networking.firewall.interfaces."br-k8s" = {
    allowedTCPPorts = [ 111 2049 ];
    allowedUDPPorts = [ 111 2049 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /persist/nfs-k8s.fsn    10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash) 172.28.7.0/24(rw,sync,no_subtree_check,no_root_squash)
      /persist/nfs-k3s.fsn    172.28.7.0/24(rw,sync,no_subtree_check,no_root_squash)
    '';
  };
}
