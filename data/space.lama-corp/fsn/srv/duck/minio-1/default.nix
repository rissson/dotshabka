{ ... }:

{
  hostId = "5c0d1caa";

  internal = {
    mac = "54:52:00:00:00:1e";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.30";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::1e";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
