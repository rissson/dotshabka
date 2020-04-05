{ config, pkgs, lib, ... }:

with lib;

let
  physicalInterface = "enp3s0";
  wirelessInterface = "wlp5s0";
in {
  networking.networkmanager.enable = false;

  networking.hostName = "hedgehog";
  networking.domain = "lama-corp.space";

  nameservers = dotshabka.data.iPs.externalNameservers;

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
          { # duck.srv.fsn.lama-corp.space
            publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
            allowedIPs = [ "172.28.0.0/16" ];
            endpoint = "duck.srv.fsn.lama-corp.space:51820";
            persistentKeepalive = 25;
          }
          { # nas.srv.bar.lama-corp.space
            publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
            allowedIPs = [ "172.28.0.0/16" ];
            endpoint = "bar.lama-corp.space:51820"; # Represents the public IP of the bar network
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
