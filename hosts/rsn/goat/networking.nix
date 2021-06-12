{ soxincfg, ... }:

with soxincfg.vars.space.lama-corp; {
  networking = with rsn.cri.goat; {
    hostName = "goat";
    domain = "cri.rsn.lama-corp.space";
    inherit hostId;
    useDHCP = false;

    bonds = {
      bond0 = {
        interfaces = [ "eno1" "enp3s0" ];
        driverOptions = {
          mode = "802.3ad";
          lacp_rate = "fast";
          xmit_hash_policy = "layer3+4";
        };
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "bond0" ];
      };
    };

    interfaces = {
      eno1 = {};
      enop3s0 = {};
      bond0 = {};
      br0 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = internal.v4.ip;
          prefixLength = internal.v4.prefixLength;
        }];
      };
    };

    firewall = {
      allowedTCPPorts = [ 5060 5061 ];
      allowedUDPPorts = [ 5060 7078 7079 9078 9079 ];
    };
  };
}
