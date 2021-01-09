{ config, ... }:

{
  networking = {
    interfaces = {
      wg0 = {
        ipv4.routes = [
          {
            address = "172.28.2.0";
            prefixLength = 24;
            via = "172.28.254.2";
          }
          /*{
            address = "192.168.3.0";
            prefixLength = 24;
            via = "172.28.254.3";
          }*/
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
        ];
      };
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [
            "172.28.254.101/24"
          ];
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
              endpoint = "86.243.114.211:51820"; # bar.lama-corp.space
              persistentKeepalive = 60;
            }
            {
              # rogue.srv.p13
              publicKey = "Oo7Nm7xCEB54fClo6ARQzJyDt8nQpisJklnbb7nWwRQ=";
              allowedIPs = [
                "172.28.254.3/32"
                "172.28.3.0/24"
              ];
              endpoint = "78.193.85.113:51820"; # p13.lama-corp.space
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
              # kvm-2.srv.fsn
              publicKey = "Ym3vm8rv4sSkqXhIiifncuf5Yu9r7TaXivkN8UACkwA=";
              allowedIPs = [
                "172.28.254.6/32"
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
  };

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
