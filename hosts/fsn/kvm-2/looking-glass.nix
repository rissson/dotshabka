{ pkgs, ... }:

let
  aliceConf = pkgs.writeText "alice.conf" ''
    [server]
    asn = 212024

    [source.edge-1-srv-par]
    name = edge-1.srv.par (IPv6)
    [source.edge-1-srv-par.birdwatcher]
    api = http://edge-1.srv.par.lama-corp.space:29184
    type = single_table
    show_last_reboot = true
  '';
in
{
  virtualisation.oci-containers.containers = {
    alice = {
      image = "alicelg/alice:4.0.3";
      ports = [
        "7340:80"
      ];
      volumes = [
        "${aliceConf}:/etc/alice-lg/alice.conf"
      ];
    };
  };
}
