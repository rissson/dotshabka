{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> {}; with fsn.srv.duck.mail-1; {
  # libvirt messes around with interfaces names, so we need to pin it
  services.udev.extraRules = ''
        SUBSYSTEM=="net", ATTR{address}=="${external.mac}", NAME="${external.interface}"
        SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
  '';

  networking = {
    hostName = "reverse-1";
    domain = "duck.srv.fsn.lama-corp.space";
    inherit hostId;

    nameservers = [
      fsn.srv.duck.internal.v4.ip
      fsn.srv.duck.internal.v6.ip
    ];

    useDHCP = false;

    interfaces = {
      "${external.interface}" = {
        ipv4.addresses = [
          { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = external.v6.ip; prefixLength = external.v6.prefixLength; }
        ];
      };
      "${internal.interface}" = {
        ipv4.addresses = [
          { address = internal.v4.ip; prefixLength = internal.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = internal.v6.ip; prefixLength = internal.v6.prefixLength; }
        ];
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

    firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22 # SSH
        80 # nginx
        443 # nginx
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
            { from = 60000; to = 61000; } # mosh
          ];
        };
      };
    };
  };
}
