{
  srv = {
    kvm-1 = {
      external = {
        bridge = "br-public";
        interface = "eno1";
        mac = "00:25:90:d8:e5:1a";
        v4 = {
          gw = "148.251.50.161";
          ip = "148.251.50.190";
          prefixLength = 32;
        };
        v6 = {
          gw = "fe80::1";
          ip = "2a01:4f8:202:1097::1";
          prefixLength = 64;
        };
      };
      internal = {
        interface = "br-local";
        mac = "54:52:00:00:00:fe";
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
          ip = "172.28.1.1";
          prefixLength = 24;
          subnet = "172.28.1.0";
        };
        v6 = {
          ip = "fd00:7fd7:e9a5:1::1";
          prefixLength = 64;
          subnet = "fd00:7fd7:e9a5:1::";
        };
      };
    };
  };

  vrt = {
    gitlab-ci-1 = {
      internal = {
        interface = "eth0";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.101";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::33";
          prefixLength = 48;
        };
      };
    };

    hub = {
      external = {
        v4 = {
          gw = "148.251.50.161";
          ip = "148.251.148.232";
          prefixLength = 32;
        };
        v6 = {
          gw = "2a01:4f8:202:1097::1";
          ip = "2a01:4f8:202:1097::2";
          prefixLength = 64;
        };
      };
      mac = "54:52:00:fb:94:e8";
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
    };

    ldap-1 = {
      internal = {
        interface = "eth0";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.10";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::a";
          prefixLength = 48;
        };
      };
    };

    lewdax = {
      external = {
        v4 = {
          gw = "148.251.50.161";
          ip = "148.251.148.233";
          prefixLength = 32;
        };
        v6 = {
          gw = "2a01:4f8:202:1097::1";
          ip = "2a01:4f8:202:1097::3";
          prefixLength = 64;
        };
      };
      mac = "54:52:00:fb:94:e9";
    };

    mail-1 = {
      external = {
        interface = "eth0";
        mac = "54:52:00:fb:94:ef";
        v4 = {
          gw = "148.251.50.190";
          ip = "148.251.148.239";
          prefixLength = 32;
        };
        v6 = {
          gw = "2a01:4f8:202:1097::1";
          ip = "2a01:4f8:202:1097::9";
          prefixLength = 64;
        };
      };
      hostId = "ad31f38a";
      internal = {
        interface = "eth1";
        mac = "54:52:00:00:00:09";
        v4 = {
          ip = "172.28.1.9";
          prefixLength = 16;
        };
        v6 = {
          ip = "fd00:7fd7:e9a5:1::9";
          prefixLength = 48;
        };
      };
    };

    minio-1 = {
      hostId = "5c0d1caa";
      internal = {
        interface = "eth1";
        mac = "54:52:00:00:00:1e";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.30";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::1e";
          prefixLength = 48;
        };
      };
    };

    postgres-1 = {
      hostId = "25eb1edf";
      internal = {
        interface = "eth1";
        mac = "54:52:00:00:00:14";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.20";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::14";
          prefixLength = 48;
        };
      };
    };

    reverse-2 = {
      external = {
        interface = "eth0";
        v4 = {
          gw = "148.251.50.190";
          ip = "148.251.148.237";
          prefixLength = 32;
        };
        v6 = {
          gw = "2a01:4f8:202:1097::1";
          ip = "2a01:4f8:202:1097::7";
          prefixLength = 64;
        };
      };
      internal = {
        interface = "eth1";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.7";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::7";
          prefixLength = 48;
        };
      };
    };

    web-1 = {
      hostId = "25eb1edf";
      internal = {
        interface = "eth1";
        mac = "54:52:00:00:00:32";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.50";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::32";
          prefixLength = 48;
        };
      };
    };

    web-2 = {
      hostId = "109bd5d9";
      internal = {
        interface = "eth1";
        mac = "54:52:00:00:00:33";
        v4 = {
          gw = "172.28.1.254";
          ip = "172.28.1.51";
          prefixLength = 16;
        };
        v6 = {
          gw = "fd00:7fd7:e9a5:1::fe";
          ip = "fd00:7fd7:e9a5:1::33";
          prefixLength = 48;
        };
      };
    };
  };
}
