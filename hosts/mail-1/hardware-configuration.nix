{ config, lib, pkgs, ... }:

{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r lpool/root@blank
  '';

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
  };

  fileSystems = {
    "/" = {
      device = "lpool/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "lpool/nix";
      fsType = "zfs";
    };
    "/var/log" = {
      device = "lpool/var/log";
      fsType = "zfs";
    };
    "/root" = {
      device = "ppool/home/root";
      fsType = "zfs";
    };
    "/srv" = {
      device = "ppool/srv";
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
