{ config, pkgs, lib, ... }:

with lib;

let

  dotshabka = import ../.. {};

in {
  networking = with dotshabka.data.iPs.space.lama-corp.bar.srv.nas; {

    hostName = "nas";
    domain = "srv.bar.lama-corp.space";
    hostId = "3474d85a";

    nameservers = dotshabka.data.iPs.externalNameservers;

    useDHCP = false;

    bonds = {
      "${internal.interface}" = {
        interfaces = internal.bondInterfaces;
        driverOptions = {
          mode = "balance-alb";
        };
      };
    };

    interfaces = {
      "${internal.interface}" = {
        ipv4.addresses = [
          { address = internal.v4.ip; prefixLength = internal.v4.prefixLength; }
        ];
      };
    };

    defaultGateway = {
      address = internal.v4.gw;
      interface = internal.interface;
    };

    wireguard = {
      enable = false; # enabled by secrets
      interfaces = {
        "${wg.interface}" = {
          ips = [ "${wg.v4.ip}/${toString wg.v4.prefixLength}" ];

          peers = [
            { # duck.srv.fsn.lama-corp.space
              publicKey = "CCA8bRHyKy7Er430MPwrNPS+PgLelCDKsaTos/Z7XXE=";
              allowedIPs = [ "172.28.0.0/${toString wg.v4.prefixLength}" ];
              endpoint = "duck.srv.fsn.lama-corp.space:51820";
              persistentKeepalive = 25;
            }
            { # hedgehog.lap.fly.lama-corp.space
              publicKey = "qBFik9hW+zN6gbT4InmhIomtV3CtJsYaRZuuEVng2Xo=";
              allowedIPs = [ "172.28.101.1/32" ];
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
        53 # DNS
        67 # DHCP
      ];
      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
      ] ++ (optionals config.networking.wireguard.enable (singleton 51820)); # Wireguard

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
      ];

      interfaces = {
        "${wg.interface}" = {
          allowedTCPPorts = [
            19999 # Netdata
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [ ];
        };
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eth0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
