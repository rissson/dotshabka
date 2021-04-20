{ config, ... }:

{
  sops.secrets.wireguard_private_key.sopsFile = ./wireguard.yml;

  networking = {
    firewall = {
      allowedUDPPorts = [
        config.networking.wireguard.interfaces.wg-kvm-2.listenPort
        config.networking.wireguard.interfaces.wg-edge-1.listenPort
        config.networking.wireguard.interfaces.wg-nas-1.listenPort
        config.networking.wireguard.interfaces.wg-mik-1.listenPort
      ];
      trustedInterfaces = [
        "wg-kvm-2" "wg-edge-1" "wg-nas-1" "wg-mik-1"
      ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg-kvm-2 = {
          ips = [ "172.28.253.3/31" "2001:67c:17fc:fffe::3/127" "fe80::172:28:254:5/64" ]; # kvm-2.edge-2.avh
          listenPort = 51002;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "168.119.71.47:51002"; # pub.kvm-2.fsn
            persistentKeepalive = 60;
          }];
        };

        wg-edge-1 = {
          ips = [ "172.28.253.5/31" "2001:67c:17fc:fffe::5/127" "fe80::172:28:254:5/64" ]; # edge-1.edge-2.avh
          listenPort = 51004;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "RBtwrX/EN9avud2yy53gziQdlzLJf1aPdk9jWtm7DHQ=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "108.61.208.236:51004"; # pub.edge-1.pvl
            persistentKeepalive = 60;
          }];
        };

        wg-nas-1 = {
          ips = [ "172.28.253.10/31" "2001:67c:17fc:fffe::a/127" "fe80::172:28:254:5/64" ]; # nas-1.edge-2.avh
          listenPort = 51010;
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
          ips = [ "172.28.253.16/31" "2001:67c:17fc:fffe::10/127" "fe80::172:28:254:5/64" ]; # mik-1.edge-2.avh
          listenPort = 51016;
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
      };
    };
  };
}
