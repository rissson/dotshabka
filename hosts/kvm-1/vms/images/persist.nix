{ config, pkgs, system }:

pkgs.vmTools.runInLinuxVM (pkgs.runCommand "libvirt-guest-image-persist" {
  memSize = 768;
  preVM = ''
    mkdir $out
    diskImage=image.qcow2
    ${pkgs.vmTools.qemu}/bin/qemu-img create -f qcow2 $diskImage 1G
    mv closure xchg/
  '';
  postVM = ''
    echo compressing VM image...
    ${pkgs.vmTools.qemu}/bin/qemu-img convert -c $diskImage -O qcow2 $out/image.qcow2
  '';

  buildInputs = with pkgs; [ utillinux perl gptfdisk e2fsprogs dosfstools ];
  exportReferencesGraph = [ "closure" config.system.build.toplevel ];
} ''
  echo creating partitions...
  # Default disk for QEMU
  DISK=/dev/vda

  sgdisk     -n1:0:0        -t4:BF01 $DISK
  mkfs.ext4 -L nixos-persist "$DISK"4
'')
