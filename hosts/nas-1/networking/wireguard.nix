{ soxincfg, config, ... }:

{
  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking = {
    interfaces = {
      wg0 = {
        ipv4.routes = [
          {
            address = "172.28.3.0";
            prefixLength = 24;
            via = "172.28.254.3";
          }
          {
            address = "172.28.4.0";
            prefixLength = 24;
            via = "172.28.254.4";
          }
          {
            address = "172.28.6.0";
            prefixLength = 24;
            via = "172.28.254.6";
          }
          {
            address = "172.28.7.0";
            prefixLength = 24;
            via = "172.28.254.6";
          }
          {
            address = "172.28.8.0";
            prefixLength = 24;
            via = "172.28.254.6";
          }
          {
            address = "172.28.254.101";
            prefixLength = 32;
            via = "172.28.254.6";
          }
          {
            address = "172.28.101.0";
            prefixLength = 24;
            via = "172.28.254.6";
          }
        ];
      };
    };

    wireguard = {
      enable = true;

      interfaces = {
        wg0 = {
          ips = [
            "172.28.254.2/24"
          ];
          privateKeyFile = config.sops.secrets.wireguard_wg0_private_key.path;
          listenPort = 51820;

          allowedIPsAsRoutes = false;
          peers = [
            {
              # kvm-2.srv.fsn
              publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
              allowedIPs = [
                "172.28.254.6/32"
                "172.28.6.0/24"
                "172.28.7.0/24"
                "172.28.8.0/24"

                # hedgehog IPs
                "172.28.254.101/24"
                "172.28.101.0/24"
              ];
              endpoint = "168.119.71.47:51820";
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
          ];
        };
      };
    };
  };

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
