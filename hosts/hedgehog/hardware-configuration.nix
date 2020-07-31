{ config, pkgs, lib, ... }:

with lib;

let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
  imports = let shabka = import <shabka> { }; in[
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${shabka.external.nixos-hardware.path}/common/cpu/amd"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"
    "${shabka.external.nixos-hardware.path}/lenovo/thinkpad"
    "${shabka.external.nixos-hardware.path}/lenovo/thinkpad/t495"

    "${impermanence}/nixos.nix"
  ];

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
    extraInitrd = /boot/initramfs.keys.gz;
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
      keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNG-L5B0B_FD02N5572108Y2J6D-part3";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNG-L5B0B_FD02N5572108Y2J6D-part4";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
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

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = mkForce "ondemand";
  };

  shabka.hardware.intel_backlight.enable = true;
}
