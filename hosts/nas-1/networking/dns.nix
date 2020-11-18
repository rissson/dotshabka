{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "loewe.mmd" = "172.28.2.221";
      "bose.mmd" = "172.28.2.222";
      "chromecast.mmd" = "172.28.2.223";
      "hp.prt" = "172.28.2.231";
      "floor0.wfi" = "172.28.2.241";
      "floor-1.wfi" = "172.28.2.242";
      "cuckoo.srv" = "172.28.2.245";
      "nas.srv" = "172.28.2.253";
      "livebox.srv" = "172.28.2.254";
    };
  };
}
