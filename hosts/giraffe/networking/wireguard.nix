{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> {}; {
  networking = with nbg.srv.giraffe; {
    wireguard = {
      enable = true;
      interfaces = with wg; {
        "${interface}" = {
          ips = [
            "${v4.ip}/${toString v4.prefixLength}"
            "${v6.ip}/${toString v6.prefixLength}"
          ];
          listenPort = 51820;
          privateKeyFile = "/srv/secrets/root/wireguard.key";

          peers = [
            {
              # duck.srv.fsn
              inherit (fsn.srv.duck.wg) publicKey;
              allowedIPs = with fsn.srv.duck.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
              endpoint = "${fsn.srv.duck.external.v4.ip}:51820";
            }
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
              # hedgehog.lap.fly
              inherit (fly.lap.hedgehog.wg) publicKey;
              allowedIPs = with fly.lap.hedgehog.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
            }
            {
              # trunck.lap.fly
              inherit (fly.lap.trunck.wg) publicKey;
              allowedIPs = with fly.lap.trunck.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
            }
          ];
        };
      };
    };
  };
}
