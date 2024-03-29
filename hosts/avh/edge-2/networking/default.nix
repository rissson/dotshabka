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
    [ "all" "default" "wg*" "ens3" ]
  );

  networking = {
    hostName = "edge-2";
    domain = "srv.vha.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "127.0.0.1" "::1" ];

    useDHCP = false;
    interfaces.ens3 = {
      useDHCP = true;
      ipv6.addresses = [
        { address = "2a00:1098:2e:2::1"; prefixLength = 64; }
      ];
    };
  };
}
