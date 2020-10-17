{
  subnet = "192.168.44.0/24";

  dhcp = {
    end = "192.168.44.199";
    start = "192.168.44.100";
  };

  mmd = {
    start = "192.168.44.220";
    end = "192.168.44.229";

    bose = {
      internal = {
        mac = "08:df:1f:08:49:34";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.222";
          prefixLength = 24;
        };
      };
    };

    chromecast = {
      internal = {
        mac = "48:d6:d5:27:2b:b4";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.223";
          prefixLength = 24;
        };
      };
    };

    loewe = {
      internal = {
        mac = "00:09:82:17:1c:c0";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.221";
          prefixLength = 24;
        };
      };
    };
  };

  prt = {
    start = "192.168.44.230";
    end = "192.168.44.239";

    hp = {
      internal = {
        mac = "88:51:fb:1b:21:f4";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.231";
          prefixLength = 24;
        };
      };
    };
  };

  srv = {
    start = "192.168.44.240";
    end = "192.168.44.255";

    cuckoo = {
      internal = {
        bridgeInterfaces = [ "enp4s11" "wls33" ];
        interface = "br0";
        mac = "12:e0:00:d1:5d:c7";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.245";
          prefixLength = 24;
        };
        wifiInterface = "wls33";
      };
    };

    livebox = {
      internal = {
        mac = "78:81:02:13:49:4e";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.254";
          prefixLength = 24;
        };
      };
    };

    nas = {
      internal = {
        bondInterfaces = [ "enp3s0" "enp4s0" ];
        interface = "bond0";
        mac = "8e:3d:9b:ab:c9:c5";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.253";
          prefixLength = 24;
        };
      };
      wg = {
        interface = "wg0";
        publicKey = "+nasSLlJuvgViVcmcCcjMFvwRLmYgGRkBed+Z6qxfw4=";
        v4 = {
          ip = "172.28.2.1";
          prefixLength = 24;
          subnet = "172.28.2.0";
        };
        v6 = {
          ip = "fd00:7fd7:e9a5:2::1";
          prefixLength = 64;
          subnet = "fd00:7fd7:e9a5:2::";
        };
      };
    };
  };

  wfi = {
    start = "192.168.44.240";
    end = "192.168.44.249";

    floor-1 = {
      internal = {
        mac = "00:e0:4c:90:a8:52";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.242";
          prefixLength = 24;
        };
      };
    };

    floor0 = {
      internal = {
        mac = "44:fe:3b:1b:ed:3e";
        v4 = {
          gw = "192.168.44.254";
          ip = "192.168.44.241";
          prefixLength = 24;
        };
      };
    };
  };
}
