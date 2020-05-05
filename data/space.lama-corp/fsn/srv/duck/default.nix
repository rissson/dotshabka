{ ... }:

{
  external = {
    mac = "00:25:90:d8:e5:1a";
    interface = "eno1";
    bridge = "br-public";
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

  internal = {
    mac = "54:52:00:00:00:fe";
    interface = "br-local";
    v4 = {
      ip = "172.28.1.254";
      prefixLength = 24;
    };
    v6 = {
      ip = "fd00:7fd7:e9a5:1::fe";
      prefixLength = 64;
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

  ldap-1 = import ./ldap-1 { };

  mail-1 = import ./mail-1 { };

  minio-1 = import ./minio-1 { };

  postgres-1 = import ./postgres-1 { };

  reverse-1 = import ./reverse-1 { };

  web-1 = import ./web-1 { };

  web-2 = import ./web-2 { };

  virt = import ./virt { };
}
