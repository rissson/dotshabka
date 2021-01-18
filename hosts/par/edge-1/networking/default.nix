{ soxincfg, lib, ... }:

{
  imports = [
    ./bird.nix
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "edge-1";
    domain = "srv.par.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "127.0.0.1" "::1" ];

    useDHCP = false;

    interfaces = {
      ens3 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = "108.61.208.236";
          prefixLength = 23;
        }];
        ipv6.addresses = [{
          address = "2a05:f480:1c00:9ee::1";
          prefixLength = 128;
        }];
      };
    };

    defaultGateway = {
      address = "108.61.208.1";
      interface = "ens3";
    };
  };
}
