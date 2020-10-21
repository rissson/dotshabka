{ ... }:

{
  hostId = "ad31f38a";

  internal = {
    mac = "54:52:00:00:00:09";
    interface = "eth0";
    v4 = {
      ip = "172.28.1.9";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::9";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
