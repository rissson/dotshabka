{ soxincfg, config, ... }:

{
  networking.firewall.allowedUDPPorts = [
    #config.networking.wireguard.interfaces.wg1.listenPort
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  networking.wireguard = {
    enable = true;

    interfaces = {
      /*wg1 = {
        ips = [
          "172.28.2.1/32"
        ];
        listenPort = 51821;
        privateKeyFile = config.sops.secrets.wireguard_wg1_private_key.path;

        peers = with soxincfg.vars.space.lama-corp; [
          {
            # kvm-1.srv.fsn
            inherit (fsn.srv.kvm-1.wg) publicKey;
            allowedIPs = with fsn.srv.kvm-1.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
            endpoint = "${fsn.srv.kvm-1.external.v4.ip}:51820";
          }
          {
            # giraffe.srv.nbg
            inherit (nbg.srv.giraffe.wg) publicKey;
            allowedIPs = with nbg.srv.giraffe.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
            endpoint = "${nbg.srv.giraffe.external.v4.ip}:51820";
          }
          {
            # trunck.lap.fly
            inherit (drn.lap.trunck.wg) publicKey;
            allowedIPs = with drn.lap.trunck.wg; [
              "${v4.subnet}/${toString v4.prefixLength}"
              "${v6.subnet}/${toString v6.prefixLength}"
            ];
          }
        ];
      };*/

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
              "172.28.254.6"
              "172.28.6.0/24"
              "172.28.7.0/24"
            ];
            endpoint = "168.119.71.47:51820";
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

  sops.secrets.wireguard_wg0_private_key.sopsFile = ./wireguard.yml;
  sops.secrets.wireguard_wg1_private_key.sopsFile = ./wireguard.yml;
}
