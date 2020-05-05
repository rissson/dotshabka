{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { };
with fsn.srv.duck.postgres-1; {
  # libvirt messes around with interfaces names, so we need to pin it
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
  '';

  networking = {
    hostName = "postgres-1";
    domain = "duck.srv.fsn.lama-corp.space";
    inherit hostId;

    nameservers = [ fsn.srv.duck.internal.v4.ip fsn.srv.duck.internal.v6.ip ];

    useDHCP = false;

    interfaces = {
      "${internal.interface}" = {
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = internal.v6.ip;
          prefixLength = internal.v6.prefixLength;
        }];
      };
    };

    defaultGateway = {
      address = internal.v4.gw;
      interface = internal.interface;
    };

    defaultGateway6 = {
      address = internal.v6.gw;
      interface = internal.interface;
    };

    firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [ ];

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];

      interfaces = {
        "${internal.interface}" = {
          allowedTCPPorts = [
            19999 # Netdata
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [
            {
              # mosh
              from = 60000;
              to = 61000;
            }
          ];
        };
      };
    };
  };
}