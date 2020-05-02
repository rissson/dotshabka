{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { }; {
  imports = [ ./firewall.nix ./wireguard.nix ];

  networking = with nbg.srv.giraffe; {

    hostName = "giraffe";
    domain = "srv.nbg.lama-corp.space";
    hostId = "13e6cd48";

    nameservers = [ "172.28.1.1" "1.1.1.1" ];

    useDHCP = false;

    interfaces = {
      "${external.interface}" = {
        ipv4.addresses = [{
          address = external.v4.ip;
          prefixLength = external.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = external.v6.ip;
          prefixLength = external.v6.prefixLength;
        }];
      };
    };

    defaultGateway = {
      address = external.v4.gw;
      interface = external.interface;
    };

    defaultGateway6 = {
      address = external.v6.gw;
      interface = external.interface;
    };
  };
}
