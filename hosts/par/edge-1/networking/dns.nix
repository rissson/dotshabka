{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "edge-1.srv.par" = "172.28.4.254";
    };
  };
}
