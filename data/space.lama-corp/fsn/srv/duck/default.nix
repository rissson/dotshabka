{ ... }:

{
  external = {
    mac = "00:25:90:d8:e5:1a";
    interface = "eno1";
    v4 = {
      ip = "148.251.50.190";
      prefixLength = 32;
      gw = "148.251.50.161";
    };
    v6 = {
      ip = "2a01:4f8:202:1097::1";
      prefixLength = 64;
      gw = "fe80::1";
    };
  };
  wg = {
    interface = "wg0";
    publicKey = "dUCkGoiEFThgLbT/30mvjbg+CU+QwQNDeccez0KmUxQ=";
    v4 = {
      subnet = "172.28.1.0";
      ip = "172.28.1.1";
      prefixLength = 24;
    };
    v6 = {
      subnet = "fd00:7fd7:e9a5:1::";
      ip = "fd00:7fd7:e9a5:1::1";
      prefixLength = 64;
    };
  };

  virt = import ./virt { };
}
