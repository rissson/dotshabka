{ soxincfg, config, ... }:

{
  sops.secrets.wireguard_private_key.sopsFile = ./wireguard.yml;

  networking = {
    firewall = {
      trustedInterfaces = [
        "wg-kvm-2" "wg-edge-1" "wg-edge-2"
      ];
    };
    wireguard = {
      enable = true;

      interfaces = {
        wg-kvm-2 = {
          ips = [ "172.28.253.7/31" "2001:67c:17fc:fffe::7/127" "fe80::172:28:254:2/64" ]; # kvm-2.nas-1.bar
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "168.119.71.47:51006"; # pub.kvm-2.fsn
            persistentKeepalive = 60;
          }];
        };

        wg-edge-1 = {
          ips = [ "172.28.253.9/31" "2001:67c:17fc:fffe::9/127" "fe80::172:28:254:2/64" ]; # edge-1.nas-1.bar
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "RBtwrX/EN9avud2yy53gziQdlzLJf1aPdk9jWtm7DHQ=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "108.61.208.236:51008"; # pub.edge-1.pvl
            persistentKeepalive = 60;
          }];
        };

        wg-edge-2 = {
          ips = [ "172.28.253.11/31" "2001:67c:17fc:fffe::b/127" "fe80::172:28:254:2/64" ]; # edge-2.nas-1.bar
          privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          allowedIPsAsRoutes = false;
          peers = [{
            publicKey = "xoQEqA/K5i/r3vXbzI0YjYGaqzUpt7T95Q0Am0SA52s=";
            allowedIPs = [
              "172.28.0.0/16"
              "2001:67c:17fc::/48"
              "ff00::/8" "fe80::/10"
            ];
            endpoint = "185.101.96.121:51010";
            persistentKeepalive = 60;
          }];
        };
      };
    };
  };
}
