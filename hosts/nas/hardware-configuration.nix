{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  boot.initrd.availableKernelModules =
    [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
  };

  fileSystems = {
    "/" = {
      device = "rpool/ROOT/nixos";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/ROOT/home";
      fsType = "zfs";
    };

    "/home/diego" = {
      device = "rpool/ROOT/home/diego";
      fsType = "zfs";
    };

    "/home/risson" = {
      device = "rpool/ROOT/home/risson";
      fsType = "zfs";
    };

    "/root" = {
      device = "rpool/ROOT/home/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/NIX/nix";
      fsType = "zfs";
    };

    "/opt" = {
      device = "rpool/ROOT/opt";
      fsType = "zfs";
    };

    "/srv" = {
      device = "rpool/ROOT/srv";
      fsType = "zfs";
    };

    "/tmp" = {
      device = "rpool/ROOT/tmp";
      fsType = "zfs";
    };

    "/var" = {
      device = "rpool/ROOT/var";
      fsType = "zfs";
    };

    "/var/cache" = {
      device = "rpool/ROOT/var/cache";
      fsType = "zfs";
    };

    "/var/lib" = {
      device = "rpool/ROOT/var/lib";
      fsType = "zfs";
    };

    "/var/lib/docker" = {
      device = "rpool/ROOT/var/lib/docker";
      fsType = "zfs";
    };

    "/var/lib/libvirt" = {
      device = "rpool/ROOT/var/lib/libvirt";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "rpool/ROOT/var/log";
      fsType = "zfs";
    };

    "/var/spool" = {
      device = "rpool/ROOT/var/spool";
      fsType = "zfs";
    };

    "/var/tmp" = {
      device = "rpool/ROOT/var/tmp";
      fsType = "zfs";
    };

    "/boot" = {
      device = "bpool/BOOT/boot";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/09a51cb0-eae7-4c25-826a-be99bf583106"; }
    { device = "/dev/disk/by-uuid/cf2e3dba-5687-4d63-987e-dde2056c8439"; }
    { device = "/dev/disk/by-uuid/9e875d9c-ce27-4ec5-b6a7-c534cd01914b"; }
  ];

  nix.maxJobs = 3;
}
