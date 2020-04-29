{ ... }:

{
  external = {
    mac = "54:52:00:fb:94:ef";
    interface = "eth0";
    v4 = {
      ip = "148.251.148.239";
      prefixLength = 32;
      gw = "148.251.50.161";
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
      ip = "192.168.45.9";
      prefixLength = 24;
      gw = "192.168.45.1";
    };
    v6 = {
      ip = "fdfb:901b:7791:45::9";
      prefixLength = 64;
      gw = "fdfb:901b:7791:45::1";
    };
  };
}
