{ config, pkgs, lib, ... }:

with lib;

let

  dotshabka = import <dotshabka> {};

in {
  networking = with dotshabka.data.iPs.space.lama-corp.nbg.srv.giraffe; {

    hostName = "giraffe";
    domain = "srv.nbg.lama-corp.space";
    hostId = "13e6cd48";

    nameservers = [
      "172.28.1.1"
      "1.1.1.1"
    ];

    useDHCP = false;

    interfaces = {
      "${external.interface}" = {
        ipv4.addresses = [
          { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = external.v6.ip; prefixLength = external.v6.prefixLength; }
        ];
      };
    };

    defaultGateway = {
      address = external.v4.gw;
      interface = external.interface;
    };

    defaultGateway6 = {
      address = external.v6.gw;
      interface = external.interface;
    };

    wireguard = {
      enable = false; # enabled by secrets
      interfaces = {
        "${wg.interface}" = {
          ips = [ "${wg.v4.ip}/${toString wg.v4.prefixLength}" ];
          listenPort = 51820;

          peers = [
            { # duck.srv.fsn.lama-corp.space
              publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
              allowedIPs = [ "172.28.0.0/${toString wg.v4.prefixLength}" ];
              endpoint = "duck.srv.fsn.lama-corp.space:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [
      ] ++ (optionals config.networking.wireguard.enable (singleton 51820)); # Wireguard

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
      ];

      interfaces = {
        "${wg.interface}" = {
          allowedTCPPorts = [
            3000 # Grafana
            19999 # Netdata
            20042 # influxdb
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [ ];
        };
      };
    };
  };
}
