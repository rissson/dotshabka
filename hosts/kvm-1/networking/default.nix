{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp/fsn> { };
with srv.kvm-1; {
  imports = [ ./dns.nix ./firewall.nix ./wireguard.nix ];

  boot.kernelParams = [
    "ip=${external.v4.ip}::${external.v4.gw}:255.255.255.224:kvm-1boot::none"
  ];

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eno1.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "kvm-1";
    domain = "srv.fsn.lama-corp.space";
    hostId = "007f0101";

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
        ipv4.routes = with vrt; [
          {
            address = hub.external.v4.ip;
            prefixLength = hub.external.v4.prefixLength;
          }
          {
            address = lewdax.external.v4.ip;
            prefixLength = lewdax.external.v4.prefixLength;
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
      enable = true;
      externalInterface = external.interface;
      internalInterfaces = [ internal.interface wg.interface ];
    };
  };
}
