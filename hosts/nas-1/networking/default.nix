{ soxincfg, ... }:

{
  # TODO: dyndns

  imports = [
    ./bird.nix
    ./dhcpd.nix
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.bond0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "nas-1";
    domain = "srv.bar.lama-corp.space";
    hostId = "3474d85a";

    nameservers = [ "127.0.0.1" "::1" ] ++ soxincfg.vars.externalNameservers;

    useDHCP = false;

    bonds = {
      bond0 = {
        interfaces = [ "enp3s0" "enp4s0" ];
      };
    };

    interfaces = {
      bond0 = {
        ipv4.addresses = [{
          address = "192.168.44.253";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = {
      address = "192.168.44.254";
      interface = "bond0";
    };
  };
}
