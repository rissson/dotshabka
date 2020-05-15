{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

rec {
  vmName = "lamacorp-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    name = vmName;
    macAddress = vrt.hub.mac;
    diskDevPath = "/dev/vg0/vm-${vmName}";
    ifBridge = srv.kvm-1.external.bridge;
  };
}