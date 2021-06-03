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
    "aes"
    "aesni_intel"
    "cryptd"
  ];

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
    zfsSupport = true;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.initrd.luks.devices = {
    cryptroot1 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNB0K302043V-part2";
      preLVM = true;
      allowDiscards = true;
    };
    cryptroot2 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNB0K502835F-part2";
      preLVM = true;
      allowDiscards = true;
    };
    cryptswap1 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNB0K302043V-part3";
      preLVM = true;
      allowDiscards = true;
    };
    cryptswap2 = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNB0K502835F-part3";
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
      device = "bpool/boot";
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

    "/efi" = {
      device = "/dev/disk/by-uuid/0DD1-1BC9";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a79a938b-a67b-4aca-95b4-154e5a96f137"; }
      { device = "/dev/disk/by-uuid/f478cf12-eb34-4f3e-8088-c6184a0161f8"; }
    ];
}
