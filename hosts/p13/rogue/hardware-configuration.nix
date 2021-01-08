{ nixos-hardware, lib, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-hdd
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  nix.maxJobs = 7;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "performance";
    powertop.enable = lib.mkForce false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    # luks stuff
    "aes_x86_64"
    "aesni_intel"
    "aesni_amd"
    "cryptd"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];

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

  boot.initrd.luks.devices = {
    cryptroot1 = {
      device = "/dev/disk/by-id/ata-HGST_HTS541010A9E680_JD1008DM2AZ47V-part3";
      preLVM = true;
    };
    cryptroot2 = {
      device = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10046P24JHJN-part3";
      preLVM = true;
    };
    cryptswap1 = {
      device = "/dev/disk/by-id/ata-HGST_HTS541010A9E680_JD1008DM2AZ47V-part4";
      preLVM = true;
    };
    cryptswap2 = {
      device = "/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10046P24JHJN-part4";
      preLVM = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
    };

    "/efi" = {
      device = "/dev/disk/by-uuid/BB2E-D5F4";
      fsType = "vfat";
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
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f71c1d86-5c66-41d2-bd9f-114d2a184538"; }
    { device = "/dev/disk/by-uuid/242aebba-3d0d-4391-9d63-a213ebc82824"; }
  ];

}
