{ soxincfg, lib, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.kvm-2-vm
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.ens3.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {
    hostName = "pine";
    domain = "vrt.fsn.lama-corp.space";
    nameservers = [ "172.28.6.254" ];

    useDHCP = false;
    dhcpcd.enable = false;

    interfaces = {
      ens3 = {
        ipv4.addresses = [{
          address = "172.28.6.201";
          prefixLength = 24;
        }];
      };
      public = {
        ipv4.addresses = [
          {
            address = "148.251.148.233";
            prefixLength = 32;
          }
        ];
        virtual = true;
      };
    };

    defaultGateway = {
      address = "172.28.6.254";
      interface = "ens3";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
