{ soxincfg, config, pkgs, lib, ... }:

{
  networking = {
    hostName = "rogue";
    domain = "srv.p13.lama-corp.space";
    hostId = "8425e349";

    nameservers = [ "1.1.1.1" ];

    interfaces = {
      enp60s0.useDHCP = true;
      wls1.useDHCP = true;
    };

    /*wireless = {
      enable = true;
      interfaces = [ "wlp1s0" ];
    };*/
  };
}
