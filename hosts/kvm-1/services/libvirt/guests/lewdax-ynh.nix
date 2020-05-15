{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

rec {
  vmName = "lewdax-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    name = vmName;
    macAddress = vrt.lewdax.mac;
    diskDevPath = "/dev/vg0/vm-${vmName}";
    ifBridge = srv.kvm-1.external.bridge;
  };
}
