{ config, pkgs, lib, ... }:

with lib;

let

  dotshabka = import <dotshabka> { };

in with import <dotshabka/data/space.lama-corp> { }; {
  networking = with bar.srv.nas; {

    hostName = "nas";
    domain = "srv.bar.lama-corp.space";
    hostId = "3474d85a";

    nameservers = [ "172.28.1.1" "1.1.1.1" ];

    useDHCP = false;

    bonds = {
      "${internal.interface}" = {
        interfaces = internal.bondInterfaces;
        driverOptions = { mode = "balance-alb"; };
      };
    };

    interfaces = {
      "${internal.interface}" = {
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
      };
    };

    defaultGateway = {
      address = internal.v4.gw;
      interface = internal.interface;
    };

    wireguard = {
      enable = true;
      interfaces = with wg; {
        "${interface}" = {
          ips = [
            "${v4.ip}/${toString v4.prefixLength}"
            "${v6.ip}/${toString v6.prefixLength}"
          ];
          listenPort = 51820;
          privateKeyFile = "/srv/secrets/root/wireguard.key";

          peers = [
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
              # hedgehog.lap.fly
              inherit (rsn.lap.hedgehog.wg) publicKey;
              allowedIPs = with rsn.lap.hedgehog.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
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
        };
      };
    };

    nat = {
      enable = true;
      externalInterface = internal.interface;
      internalInterfaces = [ wg.interface ];
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
        51820 # Wireguard
      ];

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [{
        from = 60000;
        to = 61000;
      } # mosh
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
    "net.ipv4.conf.bond0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
