{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn/srv> { };

with duck.reverse-1;

rec {
  vmName = "reverse-1";
  localDiskSize = 5;
  persistDiskSize = 1;
  xml = (pkgs.substituteAll {
    src = ../xml/vm-public.xml;

    inherit vmName;
    cpus = 2;
    ram = 2;
    macAddressPublic = external.mac;
    macAddressLocal = internal.mac;
    ifBridgePublic = duck.external.bridge;
    ifBridgeLocal = duck.internal.interface;
  });
  extraConfig = {
    networking = {
      hostName = vmName;
      domain = "";
      # required for ZFS
      inherit hostId;

      nameservers = [ duck.internal.v4.ip duck.internal.v6.ip ];

      interfaces."${external.interface}" = {
        ipv4.addresses = [{
          address = external.v4.ip;
          prefixLength = external.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = external.v6.ip;
          prefixLength = external.v6.prefixLength;
        }];
      };
      interfaces."${internal.interface}" = {
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
        ipv6.addresses = [{
          address = internal.v6.ip;
          prefixLength = internal.v6.prefixLength;
        }];
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

    # libvirt messes around with interfaces names, so we need to pin it
    services.udev.extraRules = ''
      SUBSYSTEM=="net", ATTR{address}=="${external.mac}", NAME="${external.interface}"
      SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
    '';
  };
}
