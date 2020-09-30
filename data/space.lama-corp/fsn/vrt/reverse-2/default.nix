{ ... }:

{
  external = {
    interface = "eth0";
    v4 = {
      ip = "148.251.148.237";
      prefixLength = 32;
      gw = "148.251.50.190";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::7";
      prefixLength = 64;
      gw = "2a01:4f8:202:1097::1";
    };
  };

  internal = {
    interface = "eth1";
    v4 = {
      ip = "172.28.1.7";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::7";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
