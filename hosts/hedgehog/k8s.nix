{ ... }:

{
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "hedgehog";
    easyCerts = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  networking.firewall.allowedTCPPorts = [ 6443 8888 ];
}
