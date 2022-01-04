{ config, lib, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
    };

    kernelModules = [ "kvm-intel" ];

    loader = {
      grub = {
        enable = true;
        version = 2;
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
          "/dev/sdd"
        ];
        copyKernels = true;
      };
    };
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

    "/home/diego" = {
      device = "rpool/persist/home/diego";
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

    "/persist" = {
      device = "rpool/persist/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist/media" = {
      device = "rpool/persist/persist/media";
      fsType = "zfs";
    };

    "/boot" = {
      device = "bpool/boot";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/e8e27d62-a339-4051-b497-ad7ad4062d1a"; }
    { device = "/dev/disk/by-uuid/7fe8287b-34b8-4d82-855f-80d608d27663"; }
    { device = "/dev/disk/by-uuid/b0d7137c-b904-4155-bff7-146fa0f5276c"; }
    { device = "/dev/disk/by-uuid/67a53fb0-bf92-4ad7-bb26-7669b5c8531b"; }
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nix.maxJobs = 3;

  powerManagement.cpuFreqGovernor = "performance";
}
