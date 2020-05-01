{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn/srv/duck> {};

rec {
  vmName = "lewdax-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    name = vmName;
    macaddress = virt.lewdax.mac;
    diskdevpath = "/dev/vg0/vm-${vmName}";
    ifbridge = external.bridge;
  };
}
