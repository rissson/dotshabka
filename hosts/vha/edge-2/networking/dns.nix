{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "edge-2.srv.vha" = "172.28.5.254";
    };
  };
}
