{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

rec {
  vmName = "lewdax-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    inherit vmName;
    name = vmName;
    macAddress = vrt.lewdax.mac;
    ifBridge = srv.kvm-1.external.bridge;
  };
}
