{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "rogue.srv.p13" = "172.28.3.253";
    };
  };
}
