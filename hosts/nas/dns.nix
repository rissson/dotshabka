{ pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp/bar> { };

let
  data = {
    "loewe.mmd" = mmd.loewe;
    "bose.mmd" = mmd.bose;
    "chromecast.mmd" = mmd.chromecast;
    "hp.prt" = prt.hp;
    "floor0.wfi" = wfi.floor0;
    "floor-1.wfi" = wfi.floor-1;
    "cuckoo.srv" = srv.cuckoo;
    "nas.srv" = srv.nas;
    "livebox.srv" = srv.livebox;
  };
in  {
  services.unbound.settings.server = {
    interface = with srv.nas; [ wg.v4.ip wg.v6.ip internal.v4.ip ];

    local-data = mapAttrsToList (n: v: ''"${n}.bar.lama-corp.space. IN A ${v.internal.v4.ip}"'') data;

    local-data-ptr = mapAttrsToList (n: v: ''"${v.internal.v4.ip} ${n}.bar.lama-corp.space"'') data;
  };
}
