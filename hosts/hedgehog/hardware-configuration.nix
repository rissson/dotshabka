{ config, pkgs, lib, ... }:

with lib;

{
  imports = let
    shabka = import <shabka> {};
  in [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  boot.loader.grub = {
    configurationLimit = 30;
    device = "nodev";
    efiSupport = true;
    enable = true;
    enableCryptodisk = true;
    extraInitrd = /boot/initrd.keys.gz;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.initrd.luks.devices = {
    cryptvgroot = {
      device = "/dev/disk/by-uuid/4463e27b-5bd1-4945-b4be-b5ea86ac46dd";
      preLVM = true;
      keyFile = "/keyfile0.bin";
      allowDiscards = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5e2332dc-77c3-4b59-91d2-416b25f10e0e";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/2ffe6dbb-ec89-444a-8d22-0277eb02b0c7";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/CB1A-AC4D";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9e42b003-dcee-4d78-a983-a278263916a9"; }
  ];

  nix.maxJobs = 6;

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = "powersave";
  };

  shabka.hardware.intel_backlight.enable = true;
}
