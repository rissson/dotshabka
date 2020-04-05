{ }:

{
  dhcp = {
    start = "192.168.44.100";
    end = "192.168.44.199";
  };

  srv = {
    start = "192.168.44.200";
    end = "192.168.44.209";

    cuckoo = {
      mac = "";
      internal.v4 = "192.168.44.201";
    };

    nas = {
      mac = "";
      internal.v4 = "192.168.44.253";
      wg.v4 = "172.28.2.254";
    };

    livebox = {
      mac = "";
      external.v4 = "dynamic";
      internal.v4 = "192.168.44.254";
    };
  };

  lap = {
    start = "192.168.44.210";
    end = "192.168.44.219";

    asus = {
      mac = "";
      internal.v4 = "192.168.44.211";
    };
  };

  mmd = {
    start = "192.168.44.220";
    end = "192.168.44.229";

    loewe = {
      mac = "";
      internal.v4 = "192.168.44.221";
    };

    bose = {
      mac = "";
      internal.v4 = "192.168.44.222";
    };

    chromecast = {
      mac = "";
      internal.v4 = "192.168.44.223";
    };
  };

  prt = {
    start = "192.168.44.230";
    end = "192.168.44.239";

    hp = {
      mac = "";
      internal.v4 = "192.168.44.231";
    };
  };

  wfi = {
    start = "192.168.44.240";
    end = "192.168.44.249";

    floor0 = {
      mac = "";
      internal.v4 = "192.168.44.241";
    };
  };
}
