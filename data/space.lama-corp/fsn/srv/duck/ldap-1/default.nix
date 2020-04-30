{ ... }:

{
  hostId = "1d0fe375";

  internal = {
    mac = "54:52:00:00:00:0a";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.10";
      prefixLength = 16;
      gw = "172.28.1.254";
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::10";
      prefixLength = 48;
      gw = "172.28.1.254";
    };
  };
}
