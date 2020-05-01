{ ... }:

with import <dotshabka/data/space.lama-corp> {}; {
  networking = with fly.lap.hedgehog; {
    hostName = "hedgehog";
    domain = "lap.fly.lama-corp.space";

    nameservers = [
      "172.28.1.1"
      "1.1.1.1"
    ];

    useDHCP = true;
    interfaces = {
      "enp3s0" = {
        useDHCP = true;
      };
    };

    dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';

    wireless = {
      enable = true;
      interfaces = [ "wlp5s0" ];
      extraConfig = ''
        ctrl_interface=/run/wpa_supplicant
        ctrl_interface_group=wheel
      '';
    };

    wireguard = {
      enable = true;
      interfaces = with wg; {
        "${interface}" = {
          ips = [
            "${v4.ip}/${toString v4.prefixLength}"
            "${v6.ip}/${toString v6.prefixLength}"
          ];
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
              # giraffe.srv.nbg
              inherit (nbg.srv.giraffe.wg) publicKey;
              allowedIPs = with nbg.srv.giraffe.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
              endpoint = "${nbg.srv.giraffe.external.v4.ip}:51820";
            }
            {
              # nas.srv.bar
              inherit (bar.srv.nas.wg) publicKey;
              allowedIPs = with bar.srv.nas.wg; [
                # Wireguard networks
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
                # Local networks
                #bar.subnet
              ];
              endpoint = "90.126.230.161:51820";
            }
          ];
        };
      };
    };

    networkmanager.enable = false;
  };
}