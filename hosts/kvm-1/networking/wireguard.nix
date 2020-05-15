{ config, ... }:

with import <dotshabka/data/space.lama-corp> { };
with fsn.srv.kvm-1; {
  networking.firewall.allowedUDPPorts =
    [ config.networking.wireguard.interfaces.${wg.interface}.listenPort ];

  networking.wireguard = {
    enable = true;
    interfaces = with wg; {
      "${interface}" = {
        ips = [ "${v4.ip}/32" "${v6.ip}/128" ];
        listenPort = 51820;
        privateKeyFile = "/srv/secrets/root/wireguard.key";

        peers = [
          {
            # nas.srv.bar
            inherit (bar.srv.nas.wg) publicKey;
            allowedIPs = with bar.srv.nas.wg; [
              # Wireguard networks
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
              # Local networks
              bar.subnet
            ];
          }
          {
            # giraffe.srv.nbg
            inherit (nbg.srv.giraffe.wg) publicKey;
            allowedIPs = with nbg.srv.giraffe.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
            endpoint = "${nbg.srv.giraffe.external.v4.ip}:51820";
          }
          {
            # hedgehog.lap.rsn
            inherit (rsn.lap.hedgehog.wg) publicKey;
            allowedIPs = with rsn.lap.hedgehog.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
          }
          {
            # trunck.lap.drn
            inherit (drn.lap.trunck.wg) publicKey;
            allowedIPs = with drn.lap.trunck.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
          }
        ];
      };
    };
  };
}