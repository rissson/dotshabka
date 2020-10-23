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

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "br-k8s" ];
    extraConfig = ''
      authoritative;

      option subnet-mask 255.255.255.0;
      option broadcast-address 172.28.4.255;
      option routers 172.28.4.254;
      option domain-name-servers 172.28.4.254;
      option domain-name "k8s.fsn.lama-corp.space";
      subnet 172.28.4.0 netmask 255.255.255.0 {
        range 172.28.4.230 172.28.4.240;
      }
    '';
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
      "br-k8s" = {
        interfaces = [ ];
        rstp = true;
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
            address = reverse-2.external.v4.ip;
            prefixLength = reverse-2.external.v4.prefixLength;
          }
        ];
      };

      "br-k8s" = {
        ipv4 = {
          addresses = [{
            address = "172.28.4.254";
            prefixLength = 24;
          }];
          routes = [
            {
              address = "148.251.148.234";
              prefixLength = 32;
            }
            {
              address = "148.251.148.235";
              prefixLength = 32;
            }
            {
              address = "172.28.8.0";
              prefixLength = 24;
            }
          ];
        };
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
      internalInterfaces = [ internal.interface wg.interface "ve-+" "br-k8s" ];
      internalIPs = [ "172.28.0.0/16" "10.0.0.0/8" ];
    };
  };
}
