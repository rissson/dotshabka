{ soxincfg, lib, ... }:

let
  genAttrs' = f: values: builtins.listToAttrs (lib.flatten (map f values));
in
{
  imports = [
    ./bird.nix
    ./dhcpd.nix
    ./ddns.nix
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  } // (genAttrs'
    (interface: map
      (v: {
        name = "net.${v}.conf.${interface}.rp_filter";
        value = false;
      })
      [ "ipv4" "ipv6" ]
    )
    [ "all" "default" "wg*" "bond0" "enp4s0" "enp3s0" ]
  );

  networking = {
    hostName = "nas-1";
    domain = "srv.bar.lama-corp.space";
    hostId = "8425e349";

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
          address = "172.28.2.253";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = {
      address = "172.28.2.254";
      interface = "bond0";
    };
  };
}
