{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.bind = {
    enable = true;
    cacheNetworks = [ "127.0.0.0/8" "172.28.0.0/16" "::1/128" ];
    forwarders = [ "1.1.1.1" "1.0.0.1" ];

    zones = [
      {
        name = "lama.tel";
        file = "/var/lib/bind/lama.tel.zone";
        master = false;
        masters = [
          "172.28.254.4"
        ];
        extraConfig = ''
          allow-transfer { "none"; };
        '';
      }
    ];
  };
}
