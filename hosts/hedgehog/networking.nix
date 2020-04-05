{ config, pkgs, lib, ... }:

with lib;

let
  physicalInterface = "enp3s0";
  wirelessInterface = "wlp5s0";
in {
  networking.networkmanager.enable = false;

  networking.hostName = "hedgehog";
  networking.domain = "lama-corp.space";

  networking.nameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];

  networking.useDHCP = true;
  networking.interfaces = {
    "${physicalInterface}" = {
      useDHCP = true;
    };
  };

  services.resolved.enable = true;

  networking.wireless = {
    enable = true;
    interfaces = [ "${wirelessInterface}" ];
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };

  networking.wireguard = {
    enable = false;
    interfaces = {
      "wg0" = {
        ips = [ "172.28.101.1/32" ];

        peers = [
          { # duck.srv.lama-corp.space
            publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
            allowedIPs = [ "172.28.0.0/16" ];
            endpoint = "duck.srv.fsn.lama-corp.space:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
