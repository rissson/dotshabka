{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { };
with fsn.srv.duck; {
  imports = [ ./dns.nix ./firewall.nix ./wireguard.nix ];

  boot.kernelParams = [
    "ip=${external.v4.ip}::${external.v4.gw}:255.255.255.224:duckboot::none"
  ];

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eno1.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "duck";
    domain = "srv.fsn.lama-corp.space";

    nameservers = with import <dotshabka/data> { };
      [ "127.0.0.1" "::1" ] ++ externalNameservers;

    useDHCP = false;

    bridges = {
      "${external.bridge}" = {
        interfaces = [ ];
        rstp = false;
      };
      "${internal.interface}" = {
        interfaces = [ ];
        rstp = false;
      };
    };

    interfaces = {
      "${external.interface}" = {
        ipv4.addresses = [{
          address = external.v4.ip;
          prefixLength = external.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = external.v6.ip;
          prefixLength = 128;
        }];
      };

      "${external.bridge}" = {
        ipv4.addresses = [{
          address = external.v4.ip;
          prefixLength = external.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = external.v6.ip;
          prefixLength = external.v6.prefixLength;
        }];
        ipv4.routes = [
          {
            address = virt.hub.external.v4.ip;
            prefixLength = virt.hub.external.v4.prefixLength;
          }
          {
            address = virt.lewdax.external.v4.ip;
            prefixLength = virt.lewdax.external.v4.prefixLength;
          }
          {
            address = reverse-1.external.v4.ip;
            prefixLength = reverse-1.external.v4.prefixLength;
          }
          {
            address = mail-1.external.v4.ip;
            prefixLength = mail-1.external.v4.prefixLength;
          }
        ];
      };

      "${internal.interface}" = {
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = internal.v6.ip;
          prefixLength = internal.v6.prefixLength;
        }];
        proxyARP = true; # CRITICAL TO ACCESS THE WIREGUARD
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

    nat = {
      enable = config.networking.wireguard.enable;
      externalInterface = external.interface;
      internalInterfaces = [ internal.interface wg.interface ];
    };
  };
}
