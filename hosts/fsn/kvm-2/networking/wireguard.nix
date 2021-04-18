{ config, ... }:
{
  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking = {
    interfaces = {
      wg0 = {
        ipv4.routes = [
          {
            address = "172.28.2.0";
            prefixLength = 24;
            via = "172.28.254.2";
          }
          {
            address = "192.168.3.0";
            prefixLength = 24;
            via = "172.28.254.3";
          }
          {
            address = "172.28.4.0";
            prefixLength = 24;
            via = "172.28.254.4";
          }
          {
            address = "172.28.5.0";
            prefixLength = 24;
            via = "172.28.254.5";
          }
          {
            address = "172.28.101.0";
            prefixLength = 24;
            via = "172.28.254.101";
          }
        ];
      };
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [
            "172.28.254.6/24"
          ];
          listenPort = 51820;
          privateKeyFile = config.sops.secrets.wireguard_wg0_private_key.path;

          allowedIPsAsRoutes = false;
          peers = [
            {
              # nas-1.srv.bar
              publicKey = "+nasSLlJuvgViVcmcCcjMFvwRLmYgGRkBed+Z6qxfw4=";
              allowedIPs = [
                "172.28.254.2/32"
                "172.28.2.0/24"
              ];
            }
            {
              # router-1.srv.p13
              publicKey = "/Og08yqbBnBtUQoKYx+N/S7pZ70xVWN5SP5TkGVDNlE=";
              allowedIPs = [
                "172.28.254.3/32"
                "172.28.3.0/24"
              ];
              persistentKeepalive = 60;
            }
            {
              # edge-1.srv.par
              publicKey = "RBtwrX/EN9avud2yy53gziQdlzLJf1aPdk9jWtm7DHQ=";
              allowedIPs = [
                "172.28.254.4/32"
                "172.28.4.0/24"
              ];
              endpoint = "108.61.208.236:51820";
              persistentKeepalive = 60;
            }
            {
              # edge-2.srv.vha
              publicKey = "xoQEqA/K5i/r3vXbzI0YjYGaqzUpt7T95Q0Am0SA52s=";
              allowedIPs = [
                "172.28.254.5/32"
                "172.28.5.0/24"
              ];
              endpoint = "185.101.96.121:51820";
              persistentKeepalive = 60;
            }
            {
              # hedgehog.lap.rsn
              publicKey = "KathtV0tLnk08nxuO4GkynDQi149zRg5UDMsSAdb9n8=";
              allowedIPs = [
                "172.28.254.101/32"
                "172.28.101.0/24"
              ];
            }
          ];
        };
      };
    };
  };

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
