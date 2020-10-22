{ pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp/fsn> { };

let
  data = {
    "k8s-master-11" = vrt.k8s-master-11;
    "minio-1" = vrt.minio-1;
    "postgres-1" = vrt.postgres-1;
    "reverse-2" = vrt.reverse-2;
    "web-1" = vrt.web-1;
    "web-2" = vrt.web-2;
  };
in {
  services.unbound.settings.server = {
    interface = with srv.kvm-1; [ wg.v4.ip wg.v6.ip internal.v4.ip internal.v6.ip ];

    local-data = mapAttrsToList (n: v: ''"${n}.vrt.fsn.lama-corp.space. IN A ${v.internal.v4.ip}"'') data;

    local-data-ptr = mapAttrsToList (n: v: ''"${v.internal.v4.ip} ${n}.vrt.fsn.lama-corp.space"'') data;
  };
}
