{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  nix.maxJobs = 3;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "performance";
    powertop.enable = lib.mkForce false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "rtsx_pci_sdmmc"
    "sd_mod"
    "usb_storage"
    "usbhid"
    "xhci_pci"
    # luks stuff
    "aes"
    "aesni_intel"
    "cryptd"
  ];

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

  /*boot.initrd.secrets = {
    "/crypt.keyfile" = "/srv/secrets/initrd/crypt.keyfile";
  };*/

  boot.initrd.luks.devices = {
    cryptboot = {
      device = "/dev/disk/by-id/ata-KINGSTON_SUV500240G_50026B7682336600-part2";
      preLVM = true;
      allowDiscards = true;
      #keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/ata-KINGSTON_SUV500240G_50026B7682336600-part3";
      preLVM = true;
      allowDiscards = true;
      #keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/ata-KINGSTON_SUV500240G_50026B7682336600-part4";
      preLVM = true;
      allowDiscards = true;
      #keyFile = "/crypt.keyfile";
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

    "/persist" = {
      device = "rpool/persist/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/boot" = {
      device = "bpool/boot";
      fsType = "zfs";
    };

    "/efi" = {
      device = "/dev/disk/by-uuid/06FC-CDA5";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/deb6a745-ba11-446c-b8b9-e35507f8c8cb"; }
  ];
}
