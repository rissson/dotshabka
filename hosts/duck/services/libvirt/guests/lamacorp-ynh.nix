{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn/srv/duck> { };

rec {
  vmName = "lamacorp-ynh";
  xml = pkgs.substituteAll {
    src = ../xml/ynh.xml;

    name = vmName;
    macAddress = virt.hub.mac;
    diskDevPath = "/dev/vg0/vm-${vmName}";
    ifBridge = external.bridge;
  };
}
