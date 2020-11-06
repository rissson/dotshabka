{ soxincfg, config, pkgs, lib, ... }:

with soxincfg.vars.space.lama-corp; {
  imports = [
    ./bird.nix
  ];

  networking = with rsn.lap.hedgehog; {
    hostName = "hedgehog";
    domain = "lap.rsn.lama-corp.space";
    hostId = "daec192f";

    nameservers = [ "172.28.1.1" "1.1.1.1" ];

    useDHCP = true;
    interfaces.enp3s0f0.useDHCP = true;
    interfaces.br0 = {
      ipv4.addresses = [{
        address = "192.168.1.101";
        prefixLength = 24;
      }];
    };

    bridges.br0.interfaces = [ "enp6s0f3u1u2" ];
    bridges.br0.rstp = true;

    /*dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';*/

    wireless = {
      enable = true;
      interfaces = [ "wlp1s0" ];
    };

    wireguard = {
      enable = true;
      interfaces = with wg; {
        "${interface}" = {
          ips = [
            "${v4.ip}/${toString v4.prefixLength}"
            "${v6.ip}/${toString v6.prefixLength}"
          ];
          privateKeyFile = config.sops.secrets.wireguard_wg0_private_key.path;

          peers = [
            {
              # kvm-1.srv.fsn
              inherit (fsn.srv.kvm-1.wg) publicKey;
              allowedIPs = with fsn.srv.kvm-1.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
                "172.28.4.0/24"
                "172.28.8.0/24"
              ];
              endpoint = "${fsn.srv.kvm-1.external.v4.ip}:51820";
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
              endpoint = "92.148.141.200:51820";
            }
          ];
        };
        "wg1" = {
          ips = [
            "172.28.254.101/24"
          ];
          privateKeyFile = config.sops.secrets.wireguard_wg0_private_key.path;
          allowedIPsAsRoutes = false;

          peers = [
            {
              publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
              allowedIPs = [
                "172.28.254.6"
                "172.28.6.0/24"
                "172.28.7.0/24"
              ];
              endpoint = "168.119.71.47:51820";
            }
          ];
        };
      };
    };
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
