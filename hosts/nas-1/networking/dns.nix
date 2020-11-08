{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "loewe.mmd" = "192.168.44.221";
      "bose.mmd" = "192.168.44.222";
      "chromecast.mmd" = "192.168.44.223";
      "hp.prt" = "192.168.44.231";
      "floor0.wfi" = "192.168.44.241";
      "floor-1.wfi" = "192.168.44.242";
      "cuckoo.srv" = "192.168.44.245";
      "nas.srv" = "192.168.44.253";
      "livebox.srv" = "192.168.44.254";
    };
  };
}
