{ pkgs }:

with import <dotshabka/data/space.lama-corp/fsn> { };

with srv;
with k8s.master-11;

rec {
  vmName = "k8s-master-11";
  localDiskSize = 10;
  persistDiskSize = 20;
  xml = (pkgs.substituteAll {
    src = ../vm.xml;

    inherit vmName;
    cpus = 4;
    ram = 4;
    macAddressLocal = internal.mac;
    ifBridgeLocal = "br-k8s";
  });
}
