{ ... }:

{
  hostId = "109bd5d9";

  internal = {
    mac = "54:52:00:00:00:33";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.51";
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
