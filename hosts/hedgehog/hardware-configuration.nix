{ nixos-hardware, lib, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.lenovo-thinkpad-t495
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/home/risson" = {
      device = "rpool/persist/home/risson";
      fsType = "zfs";
    };

    "/root" = {
      device = "rpool/persist/home/root";
      fsType = "zfs";
    };

    "/srv" = {
      device = "rpool/persist/srv";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var/lib/docker" = {
      device = "rpool/persist/var/lib/docker";
      fsType = "zfs";
    };

    "/var/lib/libvirt" = {
      device = "rpool/persist/var/lib/libvirt";
      fsType = "zfs";
    };

    "/boot" = {
      device = "bpool/boot";
      fsType = "zfs";
    };

    "/efi" = {
      device = "/dev/disk/by-uuid/B83E-3E69";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a76d0622-a8d2-42a6-87a6-ab24362deb02"; }
  ];
}
