{ }:

{
  srv = {
    duck = {
      external = {
        mac = "00:25:90:d8:e5:1a";
        interface = "eth0";
        v4 = {
          ip  = "148.251.50.190";
          prefixLength = 32;
          gw = "148.251.50.161";
        };
        v6 = {
          ip = "2a01:4f8:202:1097::1";
          prefixLength = 64;
          gw = "fe80::1";
        };
      };
      wg = {
        interface = "wg0";
        v4 = {
          ip = "172.28.1.1";
          prefixLength = 16;
        };
      };

      virt = {
        hub = {
          mac = "54:52:00:fb:94:e8";
          external = {
            v4 = {
              ip = "148.251.148.232";
              prefixLength = 32;
              gw = "148.251.50.161";
            };
            v6 = {
              ip = "2a01:4f8:202:1097::2";
              prefixLength = 64;
              gw = "2a01:4f8:202:1097::1";
            };
          };
          wg = {
            v4 = "172.28.1.11";
          };
        };

        lewdax = {
          mac = "54:52:00:fb:94:e9";
          external = {
            v4 = {
              ip = "148.251.148.233";
              prefixLength = 32;
              gw = "148.251.50.161";
            };
            v6 = {
              ip = "2a01:4f8:202:1097::3";
              prefixLength = 64;
              gw = "2a01:4f8:202:1097::1";
            };
          };
        };
      };
    };
  };
}
