{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

rec {
  vmName = "lewdax-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    name = vmName;
    macaddress = vrt.lewdax.mac;
    diskdevpath = "/dev/vg0/vm-${vmName}";
    ifbridge = srv.kvm-1.external.bridge;
  };
}
