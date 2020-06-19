{ config, pkgs, lib, ... }:

with lib;

{
  imports = let shabka = import <shabka> { };
  in [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc"
    "${shabka.external.nixos-hardware.path}/common/pc/ssd"
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernel.sysctl = {
    "vm.swapiness" = mkForce 10;
  };

  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.initrd.luks.devices = {
    cryptroot1 = {
      device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60M2NA0_WD-WCC3F1XXX0S3-part2";
      preLVM = true;
      allowDiscards = true;
    };
    cryptroot2 = {
      device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60M2NA0_WD-WCC3F6HLC0C3-part2";
      preLVM = true;
      allowDiscards = true;
    };
    cryptswap1 = {
      device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60M2NA0_WD-WCC3F1XXX0S3-part3";
      preLVM = true;
      allowDiscards = true;
    };
    cryptswap2 = {
      device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60M2NA0_WD-WCC3F6HLC0C3-part3";
      preLVM = true;
      allowDiscards = true;
    };
    cryptcache1 = {
      device = "/dev/disk/by-id/ata-CT240BX500SSD1_1943E3D23308-part2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    { device = "rpool/local/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/b1246b82-6c32-4cac-a4d2-4d4c1b4a4fbf";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
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

  fileSystems."/persist" =
    { device = "rpool/persist/persist";
      fsType = "zfs";
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-uuid/0DD1-1BC9";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e0297674-2230-44c4-8abb-a2c1b4528788"; }
      { device = "/dev/disk/by-uuid/9fd104c3-daca-4b76-814e-b1deb37e5002"; }
    ];

  nix.maxJobs = 7;

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = "performance";
  };
}
