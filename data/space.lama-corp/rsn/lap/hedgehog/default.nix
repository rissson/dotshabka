{ ... }:

{
  wg = {
    interface = "wg0";
    publicKey = "KathtV0tLnk08nxuO4GkynDQi149zRg5UDMsSAdb9n8=";
    v4 = {
      subnet = "172.28.101.0";
      ip = "172.28.101.1";
      prefixLength = 24;
    };
    v6 = {
      subnet = "fd00:7fd7:e9a5:101::";
      ip = "fd00:7fd7:e9a5:101::1";
      prefixLength = 64;
    };
  };
}
