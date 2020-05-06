{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { };
with fsn.vrt.ldap-1; {
  # libvirt messes around with interfaces names, so we need to pin it
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
  '';

  networking = {
    hostName = "ldap-1";
    domain = "vrt.fsn.lama-corp.space";
    inherit hostId;

    nameservers = [ fsn.srv.kvm-1.internal.v4.ip fsn.srv.kvm-1.internal.v6.ip ];

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
            389 # ldap
            19999 # Netdata
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [{
            from = 60000;
            to = 61000;
          } # mosh
            ];
        };
      };
    };
  };
}
