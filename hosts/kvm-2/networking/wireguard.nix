{ soxincfg, config, ... }:

{
  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking.wireguard = {
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
              "192.168.44.0/24"
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
    };
  };

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
}
