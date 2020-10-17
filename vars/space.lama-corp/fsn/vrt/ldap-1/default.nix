{ ... }:

{
  internal = {
    interface = "eth0";
    v4 = {
      ip = "172.28.1.10";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::a";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
