{ ... }:

{
  hostId = "2016e3d2";
  external = {
    mac = "54:52:00:fb:94:ee";
    interface = "eth0";
    v4 = {
      ip = "148.251.148.238";
      prefixLength = 32;
      gw = "148.251.50.190";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::8";
      prefixLength = 64;
      gw = "2a01:4f8:202:1097::1";
    };
  };

  internal = {
    mac = "54:52:00:00:00:08";
    interface = "eth1";
    v4 = {
      ip = "172.28.1.8";
      prefixLength = 16;
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::8";
      prefixLength = 48;
    };
  };
}
