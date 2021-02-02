{ soxincfg, ... }:

with soxincfg.vars.space.lama-corp; {
  networking = with rsn.cri.goat; {
    hostName = "goat";
    domain = "cri.rsn.lama-corp.space";
    inherit hostId;
    useDHCP = false;

    interfaces = {
      eno1 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
      };
      enp2s0 = {
        useDHCP = true;
      };
    };

    firewall = {
      allowedTCPPorts = [ 5060 5061 ];
      allowedUDPPorts = [ 5060 7078 7079 9078 9079 ];
    };
  };
}
