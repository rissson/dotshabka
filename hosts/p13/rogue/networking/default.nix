{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    ./ddns.nix
    ./dhcpd.nix
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  networking = {
    hostName = "rogue";
    domain = "srv.p13.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "127.0.0.1" "::1" ];

    interfaces = {
      enp60s0 = {
        ipv4.addresses = [{
          address = "192.168.3.253";
          prefixLength = 24;
        }];
      };

      wls1.useDHCP = true;
    };

    defaultGateway = {
      address = "192.168.3.254";
      interface = "enp60s0";
    };
  };
}
