{ soxincfg, ... }:

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
      br-k8s = {
        interfaces = [ ];
        rstp = true;
      };
    };

    interfaces = {
      enp35s0 = {
        ipv4.addresses = [{
          address = "168.119.71.47";
          prefixLength = 26;
        }];
        ipv6.addresses = [{
          address = "2a01:4f8:242:1910::1";
          prefixLength = 128;
        }];
      };

      br-k8s = {
        ipv4.addresses = [{
          address = "172.28.7.254";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = {
      address = "168.119.71.1";
      interface = "enp35s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp35s0";
    };

    nat = {
      enable = true;
      externalInterface = "enp35s0";
      internalInterfaces = [ "br-k8s" "wg0" ];
      internalIPs = [ "172.28.0.0/16" ];
    };
  };
}
