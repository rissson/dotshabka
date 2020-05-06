{ ... }:

{
  hostId = "ff20f5d0";

  internal = {
    mac = "54:52:00:00:00:c8";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.200";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::c8";
      prefixLength = 48;
      gw = "fd00:7fd7:e9a5:1::fe";
    };
  };
}
