{ }:

{
  subnet = "192.168.44.0/24";

  dhcp = {
    start = "192.168.44.100";
    end = "192.168.44.199";
  };

  srv = {
    start = "192.168.44.200";
    end = "192.168.44.209";

    cuckoo = {
      internal = {
        mac = "00:01:2e:48:df:6d";
        interface = "enp4s11";
        v4 = {
          ip  = "192.168.44.201";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };

    nas = {
      internal = {
        mac = "8e:3d:9b:ab:c9:c5";
        bondInterfaces = [ "enp3s0" "enp4s0" ];
        interface = "bond0";
        v4 = {
          ip  = "192.168.44.253";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
      wg = {
        interface = "wg0";
        v4 = {
          ip = "172.28.2.1";
          prefixLength = 16;
        };
      };
    };

    livebox = {
      internal = {
        mac = "78:81:02:13:49:4e";
        v4 = {
          ip  = "192.168.44.254";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };
  };

  lap = {
    start = "192.168.44.210";
    end = "192.168.44.219";

    asus = {
      internal = {
        mac = "94:10:3e:f6:43:35";
        v4 = {
          ip  = "192.168.44.211";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };
  };

  mmd = {
    start = "192.168.44.220";
    end = "192.168.44.229";

    loewe = {
      internal = {
        mac = "00:09:82:17:1c:c0";
        v4 = {
          ip  = "192.168.44.221";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };

    bose = {
      internal = {
        mac = "08:df:1f:08:49:34";
        v4 = {
          ip  = "192.168.44.222";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };

    chromecast = {
      internal = {
        mac = "48:d6:d5:27:2b:b4";
        v4 = {
          ip  = "192.168.44.223";
          prefixLength = 24;
          gw = "192.168.44.254";
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
          ip  = "192.168.44.231";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };
  };

  wfi = {
    start = "192.168.44.240";
    end = "192.168.44.249";

    floor0 = {
      internal = {
        mac = "44:fe:3b:1b:ed:3e";
        v4 = {
          ip  = "192.168.44.241";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };

    floor-1 = {
      internal = {
        mac = "00:e0:4c:90:a8:52";
        v4 = {
          ip  = "192.168.44.242";
          prefixLength = 24;
          gw = "192.168.44.254";
        };
      };
    };
  };
}
