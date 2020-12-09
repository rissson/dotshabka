{ lib, ... }:

{
  hardware.enableRedistributableFirmware = true;

  nix.maxJobs = 3;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "performance";
  };

  boot = {
    kernelParams = [ "elevator=none" ];

    initrd = {
      availableKernelModules = [
        "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "ums_realtek" "usb_storage"
        "usbhid" "sd_mod"
      ];
    };

    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/disk/by-id/ata-FUJITSU_MJA2320BH_G2_K92MT99289W0";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
    };

    "/boot" = {
      device = "bpool/boot";
      fsType = "zfs";
    };

    "/etc" = {
      device = "rpool/local/etc";
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

    "/persist" = {
      device = "rpool/persist/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [ ];
}
