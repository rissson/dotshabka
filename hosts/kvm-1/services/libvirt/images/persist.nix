{ config, pkgs, system, hostId }:

let
  vmTools = pkgs.callPackage "${pkgs.path}/pkgs/build-support/vm" {
    kernel = config.system.modulesTree.override { name = "kernel-modules"; };
    rootModules = [
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_balloon"
      "virtio_rng"
      "ext4"
      "unix"
      "9p"
      "9pnet_virtio"
      "crc32c_generic"
      "zfs"
      "spl"
    ];
  };

  config = (import <nixpkgs/nixos/lib/eval-config.nix> {
    inherit system;
    modules = [{
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "virtio_balloon"
        "virtio_blk"
        "virtio_pci"
        "virtio_ring"
        "aes_x86_64"
        "aesni_intel"
        "cryptd"
      ];
      boot.supportedFilesystems = [ "zfs" ];
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelParams = [ "elevator=none" ];
      boot.loader.grub.device = "/dev/vda";
      fileSystems."/" = {
        device = "lpool/root";
        fsType = "zfs";
      };
      networking.hostId = hostId;
    }];
  }).config;

in vmTools.runInLinuxVM (pkgs.runCommand "libvirt-guest-image-persist" {
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

  buildInputs = with pkgs; [ utillinux perl gptfdisk zfs e2fsprogs dosfstools ];
  exportReferencesGraph = [ "closure" config.system.build.toplevel ];
} ''
  echo creating partitions...
  # Default disk for QEMU
  DISK=/dev/vda

  # Create the zfs pool
  zpool create -o ashift=12 -O acltype=posixacl -O canmount=off \
    -O compression=on -O dnodesize=auto -O normalization=formD \
    -O relatime=on -O xattr=sa -O mountpoint=none \
    ppool "$DISK"

  zfs set com.sun:auto-snapshot=true ppool

  zfs create -o mountpoint=none ppool/home
  zfs create -o mountpoint=legacy ppool/home/root
  zfs create -o mountpoint=legacy ppool/srv
'')
