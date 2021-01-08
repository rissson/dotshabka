{ soxincfg, config, pkgs, lib, ... }:

{
  networking = {
    hostName = "rogue";
    domain = "srv.p13.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "1.1.1.1" ];

    interfaces = {
      enp60s0 = {
        ipv4.addresses = [{
          address = "192.168.1.253";
          prefixLength = 24;
        }];
      };

      wls1.useDHCP = true;
    };

    defaultGateway = {
      address = "192.168.1.254";
      interface = "enp60s0";
    };

    /*wireless = {
      enable = true;
      interfaces = [ "wls1" ];
    };*/
  };
}
