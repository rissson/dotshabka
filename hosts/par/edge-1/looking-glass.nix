{ ... }:

{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 29184 ];

  virtualisation.oci-containers.containers = {
    birdwatcher = {
      image = "alicelg/birdwatcher:2.2.0";
      ports = [
        "29184:29184"
      ];
      volumes = [
        "/run/bird.ctl:/usr/local/var/run/bird.ctl"
      ];
    };
  };
}
