{ config, pkgs, lib, ... }:

with lib;

{
  imports = let shabka = import <shabka> { };
  in [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${shabka.external.nixos-hardware.path}/common/cpu/amd"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"
    "${shabka.external.nixos-hardware.path}/lenovo/thinkpad"
    "${shabka.external.nixos-hardware.path}/lenovo/thinkpad/t495"
  ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "aes_x86_64" "aesni_amd" "cryptd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "elevator=none" ];

  boot.initrd.postDeviceCommands = mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
    zfsSupport = true;
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

  fileSystems."/" =
    { device = "rpool/local/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    { device = "rpool/local/var/log";
      fsType = "zfs";
    };

  fileSystems."/home/risson" =
    { device = "rpool/persist/home/risson";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "rpool/persist/home/root";
      fsType = "zfs";
    };

  fileSystems."/srv" =
    { device = "rpool/persist/srv";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "rpool/persist/var/lib/docker";
      fsType = "zfs";
    };

  fileSystems."/var/lib/libvirt" =
    { device = "rpool/persist/var/lib/libvirt";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "bpool/boot";
      fsType = "zfs";
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-uuid/B83E-3E69";
      fsType = "vfat";
    };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a76d0622-a8d2-42a6-87a6-ab24362deb02"; }
  ];

  nix.maxJobs = 7;

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = "ondemand";
  };

  shabka.hardware.intel_backlight.enable = true;
}
