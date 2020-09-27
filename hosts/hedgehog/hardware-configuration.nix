{ config, pkgs, lib, nixos-hardware, ... }:

with lib;

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.lenovo-thinkpad-t495
  ];

  hardware.enableRedistributableFirmware = true;

  environment.persistence."/srv" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "ehci_pci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];

  boot.kernelModules = [ "kvm-amd" ];

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    # TODO: migrate to new config option
    #extraInitrd = /boot/initramfs.keys.gz;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.initrd.luks.devices = {
    cryptboot = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNG-L5B0B_FD02N5572108Y2J6D-part2";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNG-L5B0B_FD02N5572108Y2J6D-part3";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNG-L5B0B_FD02N5572108Y2J6D-part4";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
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

  nix.maxJobs = 7;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = mkForce "ondemand";
  };


  # Give people part of the video group access to adjust the backlight
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';
}
