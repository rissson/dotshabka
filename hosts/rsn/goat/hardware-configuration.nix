{ nixos-hardware, lib, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  nix.maxJobs = 7;

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/kubernetes"
      "/var/lib/etcd"
      "/var/lib/cfssl"
      "/var/lib/kubelet"

      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "ahci"
    "usbhid"
    # luks stuff
    "aes_x86_64"
    "aesni_intel"
    "aesni_amd"
    "cryptd"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernel.sysctl = {
    "vm.swapiness" = lib.mkForce 10;
  };

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

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/b1246b82-6c32-4cac-a4d2-4d4c1b4a4fbf";
      fsType = "ext4";
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

    "/efi" = {
      device = "/dev/disk/by-uuid/0DD1-1BC9";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e0297674-2230-44c4-8abb-a2c1b4528788"; }
      { device = "/dev/disk/by-uuid/9fd104c3-daca-4b76-814e-b1deb37e5002"; }
    ];
}
