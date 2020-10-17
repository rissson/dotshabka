{ pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp/fsn> { };

let
  data = {
    "minio-1.vrt" = vrt.minio-1;
    "postgres-1.vrt" = vrt.postgres-1;
    "reverse-2.vrt" = vrt.reverse-2;
    "master-11.k8s" = k8s.master-11;
  };
in {
  services.unbound.settings.server = {
    interface = with srv.kvm-1; [ wg.v4.ip wg.v6.ip internal.v4.ip internal.v6.ip "172.28.4.254" ];

    local-data = mapAttrsToList (n: v: ''"${n}.fsn.lama-corp.space. IN A ${v.internal.v4.ip}"'') data;

    local-data-ptr = mapAttrsToList (n: v: ''"${v.internal.v4.ip} ${n}.fsn.lama-corp.space"'') data;
  };
}
