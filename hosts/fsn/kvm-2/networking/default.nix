{ soxincfg, lib, ... }:

{
  imports = [
    ./bird.nix
    ./dhcpd.nix
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  boot.kernelParams = [
    "ip=168.119.71.47::168.119.71.1:255.255.255.192:kvm-2-boot::none"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.enp35s0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "kvm-2";
    domain = "srv.fsn.lama-corp.space";
    hostId = "9e305ad6";

    nameservers = [ "127.0.0.1" "::1" ] ++ soxincfg.vars.externalNameservers;

    useDHCP = false;

    bridges = {
      br-vms = {
        interfaces = [ ];
        rstp = true;
      };

      br-k8s = {
        interfaces = [ ];
        rstp = true;
      };
    };

    vlans = {
      "enp35s0.4004" = {
        id = 4004;
        interface = "enp35s0";
      };
    };

    interfaces = {
      enp35s0 = {
        ipv4.addresses = [{
          address = "168.119.71.47";
          prefixLength = 26;
        }];
        /*ipv6.addresses = [{
          address = "2a01:4f8:242:1910::1";
          prefixLength = 128;
        }];*/
      };

      br-vms = {
        ipv4.addresses = [{
          address = "172.28.6.254";
          prefixLength = 24;
        }];
        ipv4.routes = [
          {
            address = "148.251.148.232";
            prefixLength = 32;
            via = "172.28.6.11";
          }
          {
            address = "148.251.148.233";
            prefixLength = 32;
            via = "172.28.6.201";
          }
        ];
      };

      br-k8s = {
        ipv4.addresses = [{
          address = "172.28.7.254";
          prefixLength = 24;
        }];
      };

      he-ipv6 = {
        ipv6.addresses = [{
          address = "2001:470:1f0a:1308::2";
          prefixLength = 64;
        }];
        mtu = 1480;
        virtual = true;
      };
    };

    defaultGateway = {
      address = "168.119.71.1";
      interface = "enp35s0";
    };
    defaultGateway6 = {
      address = "2001:470:1f0a:1308::1";
      interface = "he-ipv6";
    };

    nat = {
      enable = true;
      externalInterface = "enp35s0";
      internalInterfaces = [ "br-vms" "br-k8s" ];
      internalIPs = [ "172.28.6.0/24" "172.28.7.0/24" ];
    };

    sits = {
      he-ipv6 = {
        dev = "enp35s0";
        remote = "216.66.80.30";
        local = "168.119.71.47";
        ttl = 255;
      };
    };
  };
}
