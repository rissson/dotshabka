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
                "172.28.8.0/24"
              ];
              endpoint = "168.119.71.47:51820";
              persistentKeepalive = 60;
            }
          ];
        };
      };
    };

    localCommands = let ethtool = "${pkgs.ethtool}/bin/ethtool"; in ''
      ip link del myfw-in-nsin
      ip link del myfw-in-nsfw
      ip link del myfw-out-nsout
      ip link del myfw-out-nsfw

      ip netns delete nsin
      ip netns delete nsfw
      ip netns delete nsout

      ip netns add nsin
      ip netns add nsfw
      ip netns add nsout

      ip link add myfw-in-nsin type veth peer name myfw-in-nsfw
      ip link set dev myfw-in-nsin netns nsin up
      ip link set dev myfw-in-nsfw netns nsfw up

      ip netns exec nsin ${ethtool} -K myfw-in-nsin tx off
      ip netns exec nsfw ${ethtool} -K myfw-in-nsfw tx off

      ip netns exec nsin ip addr add fd00::0/127 dev myfw-in-nsin

      ip link add myfw-out-nsout type veth peer name myfw-out-nsfw
      ip link set dev myfw-out-nsout netns nsout up
      ip link set dev myfw-out-nsfw netns nsfw up

      ip netns exec nsout ${ethtool} -K myfw-out-nsout tx off
      ip netns exec nsfw ${ethtool} -K myfw-out-nsfw tx off

      ip netns exec nsout ip addr add fd00::1/127 dev myfw-out-nsout
    '';
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
