{ soxincfg, lib, ... }:

let
  genAttrs' = f: values: builtins.listToAttrs (lib.flatten (map f values));
in
{
  imports = [
    ./bird.nix
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
    [ "all" "default" "wg*" "wg-cri" "ens3" ]
  );

  networking = {
    hostName = "edge-1";
    domain = "srv.par.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "127.0.0.1" "::1" ];

    useDHCP = false;
    interfaces.ens3.useDHCP = true;
  };
}
