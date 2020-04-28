{ }:

{
  space.lama-corp = {
    nbg = {
      srv = {
        giraffe = {
          external = {
            mac = "96:00:00:4f:07:af";
            interface = "ens3";
            v4 = {
              ip  = "78.46.241.184";
              prefixLength = 32;
              gw = "172.31.1.1";
            };
            v6 = {
              ip = "2a01:4f8:c0c:1f9a::1";
              prefixLength = 64;
              gw = "fe80::1";
            };
          };
          wg = {
            interface = "wg0";
            v4 = {
              ip = "172.28.3.1";
              prefixLength = 16;
            };
          };
        };
      };
    };
    fsn = import ./fsn.nix { };
    bar = import ./bar.nix { };
    fly = {
      lap = {
        hedgehog = {
          wg = {
            interface = "wg0";
            v4 = {
              ip = "172.28.101.1";
              prefixLength = 16;
            };
          };
        };
        trunck = {
          wg = {
            interface = "wg0";
            v4 = {
              ip = "172.28.102.1";
              prefixLength = 16;
            };
          };
        };
      };
    };
  };

  externalNameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];
}
