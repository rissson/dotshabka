{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    ./ddns.nix
  ];

  networking = {
    hostName = "storj-1";
    domain = "p13.lama.tel";
    hostId = "8425e349";

    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    interfaces = {
      eno1 = {
        ipv4.addresses = [{
          address = "172.28.3.10";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = {
      address = "172.28.3.254";
      interface = "eno1";
    };
  };
}
