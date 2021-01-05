{ config, ... }:
{
  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
    config.networking.wireguard.interfaces.wg212270.listenPort
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
            address = "172.28.3.0";
            prefixLength = 24;
            via = "172.28.254.3";
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
            "172.28.254.4/24"
          ];
          listenPort = 51820;
          privateKeyFile = config.sops.secrets.wireguard_wg0_private_key.path;

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
              ];
              endpoint = "168.119.71.47:51820";
              persistentKeepalive = 60;
            }
            {
              # nas-1.srv.bar
              publicKey = "+nasSLlJuvgViVcmcCcjMFvwRLmYgGRkBed+Z6qxfw4=";
              allowedIPs = [
                "172.28.254.2/32"
                "172.28.2.0/24"
              ];
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

        wg212270 = {
          ips = [
            "fd3c:c1c4:bbff:9a64::ee1/64"
          ];
          listenPort = 51821;
          privateKeyFile = config.sops.secrets.wireguard_wg212270_private_key.path;

          allowedIPsAsRoutes = false;
          peers = [
            {
              # kvm-2.srv.fsn.lama-corp.space
              publicKey = "G25/lrHkH+zHkRFsTQl0B/tqnZTFP1fTQSJV5wvb4QM=";
              allowedIPs = [
                "fd3c:c1c4:bbff:9a64::dead:beef/128"
              ];
              endpoint = "[2a01:4f8:242:1910::1]:51821";
              persistentKeepalive = 60;
            }
            {
              # tonkinois.core.vlt.phowork.fr
              publicKey = "E1EBL3208LQ6xt3NmxSQdkgmrPMH6bjO0tTDdASJPR8=";
              allowedIPs = [
                "fd3c:c1c4:bbff:9a64::cafe/128"
                "2a0f:9240:2000::/48"
                "2a0e:b107:f50::/44"
              ];
              endpoint = "[2a05:f480:1c00:4c8:5400:3ff:fe1f:ae47]:51823";
              persistentKeepalive = 60;
            }
            {
              # colibri.deliciousmuffins.net
              publicKey = "GHq5ONIpnsgdrBar2fvIgWCfPWK5wKi4LUmF6MBjIjU=";
              allowedIPs = [
                "fd3c:c1c4:bbff:9a64::4251/128"
                "2001:db8:4251::/48"
              ];
              endpoint = "[2a05:f480:1c00:e18:5400:3ff:fe21:317a]:51820";
              persistentKeepalive = 60;
            }
          ];
        };
      };
    };
  };

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
  sops.secrets.wireguard_wg212270_private_key.sopsFile = ./wireguard.yml;
}
