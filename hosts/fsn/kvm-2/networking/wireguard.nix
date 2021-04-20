{ config, ... }:

{
  sops.secrets.wireguard_private_key.sopsFile = ./wireguard.yml;

  networking = {
    firewall = {
      allowedUDPPorts = [
        config.networking.wireguard.interfaces.wg-edge-1.listenPort
        config.networking.wireguard.interfaces.wg-edge-2.listenPort
        config.networking.wireguard.interfaces.wg-nas-1.listenPort
        config.networking.wireguard.interfaces.wg-mik-1.listenPort
      ];
      trustedInterfaces = [
        "wg-edge-1" "wg-edge-2" "wg-nas-1" "wg-mik-1"
      ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg-edge-1 = {
          ips = [ "172.28.253.0/31" "2001:67c:17fc:fffe::0/127" "fe80::172:28:254:6/64" ]; # edge-1.kvm-2.fsn
          listenPort = 51000;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "RBtwrX/EN9avud2yy53gziQdlzLJf1aPdk9jWtm7DHQ=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "108.61.208.236:51000"; # pub.edge-1.pvl
            persistentKeepalive = 60;
          }];
        };

        wg-edge-2 = {
          ips = [ "172.28.253.2/31" "2001:67c:17fc:fffe::2/127" "fe80::172:28:254:6/64" ]; # edge-2.kvm-2.fsn
          listenPort = 51002;
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "xoQEqA/K5i/r3vXbzI0YjYGaqzUpt7T95Q0Am0SA52s=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "185.101.96.121:51002"; # pub.edge-2.avh
            persistentKeepalive = 60;
          }];
        };

        wg-nas-1 = {
          ips = [ "172.28.253.6/31" "2001:67c:17fc:fffe::6/127" "fe80::172:28:254:6/64" ]; # nas-1.kvm-2.fsn
          listenPort = 51006;
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
          ips = [ "172.28.253.12/31" "2001:67c:17fc:fffe::c/127" "fe80::172:28:254:6/64" ]; # mik-1.kvm-2.fsn
          listenPort = 51012;
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
