{ ... }:

{
  mac = "54:52:00:fb:94:e9";
  external = {
    v4 = {
      ip = "148.251.148.233";
      prefixLength = 32;
      gw = "148.251.50.161";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::3";
      prefixLength = 64;
      gw = "2a01:4f8:202:1097::1";
    };
  };
}