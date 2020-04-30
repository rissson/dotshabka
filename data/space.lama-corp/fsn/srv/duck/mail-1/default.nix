{ ... }:

{
  hostId = "ad31f38a";
  external = {
    mac = "54:52:00:fb:94:ef";
    interface = "eth0";
    v4 = {
      ip = "148.251.148.239";
      prefixLength = 32;
      gw = "148.251.50.190";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::9";
      prefixLength = 64;
      gw = "2a01:4f8:202:1097::1";
    };
  };

  internal = {
    mac = "54:52:00:00:00:09";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.9";
      prefixLength = 16;
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::9";
      prefixLength = 48;
    };
  };
}
