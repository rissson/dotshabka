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
    interfaces.ens3.useDHCP = true;
  };
}
