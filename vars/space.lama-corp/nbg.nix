{
  srv = {
    giraffe = {
      external = {
        interface = "ens3";
        mac = "96:00:00:4f:07:af";
        v4 = {
          gw = "172.31.1.1";
          ip = "78.46.241.184";
          prefixLength = 32;
        };
        v6 = {
          gw = "fe80::1";
          ip = "2a01:4f8:c0c:1f9a::1";
          prefixLength = 64;
        };
      };
      wg = {
        interface = "wg0";
        publicKey = "GrGIRAF3f1bcFLBTK9u+RzsjeZt6JXYrBwJnsFGo7zo=";
        v4 = {
          ip = "172.28.3.1";
          prefixLength = 24;
          subnet = "172.28.3.0";
        };
        v6 = {
          ip = "fd00:7fd7:e9a5:3::1";
          prefixLength = 64;
          subnet = "fd00:7fd7:e9a5:3::";
        };
      };
    };
  };
}
