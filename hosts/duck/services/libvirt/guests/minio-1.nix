{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn/srv> { };

with duck.minio-1;

rec {
  vmName = "minio-1";
  localDiskSize = 10;
  persistDiskSize = 20;
  xml = (pkgs.substituteAll {
    src = ../xml/vm-local.xml;

    inherit vmName;
    cpus = 2;
    ram = 2;
    macAddressLocal = internal.mac;
    ifBridgeLocal = duck.internal.interface;
  });
  extraConfig = {
    networking = {
      hostName = vmName;
      domain = "";
      # required for ZFS
      inherit hostId;

      nameservers = [ duck.internal.v4.ip duck.internal.v6.ip ];

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
        address = internal.v4.gw;
        interface = internal.interface;
      };

      defaultGateway6 = {
        address = internal.v6.gw;
        interface = internal.interface;
      };
    };

    # libvirt messes around with interfaces names, so we need to pin it
    services.udev.extraRules = ''
      SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
    '';
  };
}
