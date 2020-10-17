{ ... }:

{
  internal = {
    interface = "eth0";
    v4 = {
      ip = "172.28.1.101";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::33";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
