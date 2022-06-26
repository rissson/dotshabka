{ soxincfg, ... }:

{
  networking = {
    hostName = "horse";
    domain = "p13.lama.tel";
    hostId = "8425e349";
    useDHCP = false;

    interfaces = {
      enp5s0 = {
        useDHCP = true;
      };
    };
  };
}
