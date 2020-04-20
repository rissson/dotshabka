{ ... }:

{
  networking = {
    hostName = "hedgehog";
    domain = "lap.fly.lama-corp.space";

    nameservers = [
      "172.28.1.1"
      "1.1.1.1"
    ];

    useDHCP = true;
    interfaces = {
      "enp3s0" = {
        useDHCP = true;
      };
    };

    dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';

    wireless = {
      enable = true;
      interfaces = [ "wlp5s0" ];
      extraConfig = ''
        ctrl_interface=/run/wpa_supplicant
        ctrl_interface_group=wheel
      '';
    };

    wireguard = {
      enable = false;
      interfaces = {
        "wg0" = {
          ips = [ "172.28.101.1/16" ];

          peers = [
            { # duck.srv.fsn.lama-corp.space
              publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
              allowedIPs = [ "172.28.0.0/16" "192.168.44.0/24" ];
              endpoint = "duck.srv.fsn.lama-corp.space:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    networkmanager.enable = false;
  };
}
