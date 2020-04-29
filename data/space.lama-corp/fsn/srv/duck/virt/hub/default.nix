{ ... }:

{
  mac = "54:52:00:fb:94:e8";
  external = {
    v4 = {
      ip = "148.251.148.232";
      prefixLength = 32;
      gw = "148.251.50.161";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::2";
      prefixLength = 64;
      gw = "2a01:4f8:202:1097::1";
    };
  };
  wg = {
    publicKey = "xa3HxQyrwM+uR8/NqiOCzonwOCqSD/ghkFow4d1omkQ=";
    v4 = {
      ip = "172.28.1.101";
      prefixLength = 24;
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::101";
      prefixLength = 64;
    };
  };
}
