{ }:

{
  space.lama-corp = {
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
      };
    };
  };

  externalNameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];
}
