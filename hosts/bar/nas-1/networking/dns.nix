{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "loewe.mmd.bar" = "172.28.2.221";
      "bose.mmd.bar" = "172.28.2.222";
      "chromecast.mmd.bar" = "172.28.2.223";
      "hp.prt.bar" = "172.28.2.231";
      "floor0.wfi.bar" = "172.28.2.241";
      "floor-1.wfi.bar" = "172.28.2.242";
      "cuckoo.srv.bar" = "172.28.2.245";
      "nas.srv.bar" = "172.28.2.253";
      "livebox.srv.bar" = "172.28.2.254";
    };
  };
}
