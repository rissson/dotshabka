{ config, lib, pkgs, ... }:

with lib;

{
  imports = let
    shabka = import <shabka> {};
  in [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/hdd"
  ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci"
    "usbhid" "usb_storage" "sd_mod" "virtio_balloon" "virtio_blk"
    "virtio_pci" "virtio_ring"
  ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "elevator=none" ];

  boot.initrd.postDeviceCommands = mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
    zfsSupport = true;
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-09 04:08:02 UTC";
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };
    "/root" = {
      device = "rpool/persist/home/root";
      fsType = "zfs";
    };
    "/srv" = {
      device = "rpool/persist/srv";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/nixos-boot";
      fsType = "ext4";
    };
    "/efi" = {
      device = "/dev/disk/by-label/nixos-efi";
      fsType = "vfat";
    };
  };

  nix.maxJobs = 2;
}
