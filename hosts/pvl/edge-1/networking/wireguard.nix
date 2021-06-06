{ config, ... }:
{
  sops.secrets.wireguard_private_key.sopsFile = ./wireguard.yml;
  sops.secrets.wireguard_wg-cri_private_key.sopsFile = ./wireguard.yml;

  networking = {
    firewall = {
      allowedUDPPorts = [
        config.networking.wireguard.interfaces.wg-kvm-2.listenPort
        config.networking.wireguard.interfaces.wg-edge-2.listenPort
        config.networking.wireguard.interfaces.wg-nas-1.listenPort
        config.networking.wireguard.interfaces.wg-mik-1.listenPort

        config.networking.wireguard.interfaces.wge-cri.listenPort
      ];
      trustedInterfaces = [
        "wg-kvm-2" "wg-edge-2" "wg-nas-1" "wg-mik-1"
      ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg-kvm-2 = {
          ips = [ "172.28.253.1/31" "2001:67c:17fc:fffe::1/127" "fe80::172:28:254:4/64" ]; # kvm-2.edge-1.pvl
          listenPort = 51000;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "168.119.71.47:51000"; # pub.kvm-2.fsn
            persistentKeepalive = 60;
          }];
        };

        wg-edge-2 = {
          ips = [ "172.28.253.4/31" "2001:67c:17fc:fffe::4/127" "fe80::172:28:254:4/64" ]; # edge-2.edge-1.pvl
          listenPort = 51004;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "xoQEqA/K5i/r3vXbzI0YjYGaqzUpt7T95Q0Am0SA52s=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "185.101.96.121:51004"; # pub.edge-2.avh
            persistentKeepalive = 60;
          }];
        };

        wg-nas-1 = {
          ips = [ "172.28.253.8/31" "2001:67c:17fc:fffe::8/127" "fe80::172:28:254:4/64" ]; # nas-1.edge-1.pvl
          listenPort = 51008;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "+nasSLlJuvgViVcmcCcjMFvwRLmYgGRkBed+Z6qxfw4=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            persistentKeepalive = 60;
          }];
        };

        wg-mik-1 = {
          ips = [ "172.28.253.14/31" "2001:67c:17fc:fffe::e/127" "fe80::172:28:254:4/64" ]; # mik-1.edge-1.pvl
          listenPort = 51014;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "/Og08yqbBnBtUQoKYx+N/S7pZ70xVWN5SP5TkGVDNlE=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            persistentKeepalive = 60;
          }];
        };

        wge-cri = {
          ips = [
            "fd3c:c1c4:bbff:9a64::ee1/64"
          ];
          listenPort = 51821;
          privateKeyFile = config.sops.secrets.wireguard_wg-cri_private_key.path;

          allowedIPsAsRoutes = false;
          peers = [
            {
              # tonkinois.edge.vlt.phowork.fr
              publicKey = "E1EBL3208LQ6xt3NmxSQdkgmrPMH6bjO0tTDdASJPR8=";
              allowedIPs = [
                "fd3c:c1c4:bbff:9a64::cafe/128"
                "2a0f:9240:2000::/48"
                "2a0e:b107:f50::/44"
              ];
              endpoint = "[2001:19f0:6801:7c4:5400:3ff:fe47:7968]:51823";
              persistentKeepalive = 60;
            }
            {
              # colibri.deliciousmuffins.net
              publicKey = "GHq5ONIpnsgdrBar2fvIgWCfPWK5wKi4LUmF6MBjIjU=";
              allowedIPs = [
                "fd3c:c1c4:bbff:9a64::4251/128"
                "2001:67c:229c::/48"
                "2a06:3881:7800::/40"
              ];
              endpoint = "[2a05:f480:1c00:e18:5400:3ff:fe21:317a]:51820";
              persistentKeepalive = 60;
            }
          ];
        };
      };
    };
  };
}
