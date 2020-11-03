{ config, ... }:

{
  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      ips = [ "172.28.254.6/32" ];
      listenPort = 51820;
      privateKeyFile = "/persist/secrets/wireguard/key";

      allowedIPsAsRoutes = false;
      peers = [
        {
          # nas.srv.bar
          inherit (soxincfg.vars.space.lama-corp.bar.srv.nas.wg) publicKey;
          allowedIPs = [
            "172.28.254.2/32"
            "172.28.2.0/24"
            "192.168.44.0/24"
          ];
        }
      ];
    };
  };
}
