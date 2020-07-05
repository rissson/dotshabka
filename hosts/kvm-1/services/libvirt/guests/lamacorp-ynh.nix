{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

rec {
  vmName = "lamacorp-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    inherit vmName;
    name = vmName;
    macAddress = vrt.hub.mac;
    ifBridge = srv.kvm-1.external.bridge;
  };
}
