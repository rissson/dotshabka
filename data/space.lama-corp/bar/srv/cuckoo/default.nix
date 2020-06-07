{ ... }:

{
  internal = rec {
    mac = "12:e0:00:d1:5d:c7";
    wifiInterface = "wls33";
    bridgeInterfaces = [ "enp4s11" wifiInterface ];
    interface = "br0";
    v4 = {
      ip = "192.168.44.245";
      prefixLength = 24;
      gw = "192.168.44.254";
    };
  };
}
