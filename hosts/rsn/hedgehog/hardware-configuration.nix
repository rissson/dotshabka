{ nixos-hardware, lib, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.lenovo-thinkpad-t495
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_14;

  nix.maxJobs = 7;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "ondemand";
    powertop.enable = lib.mkForce false;
  };

  environment.persistence."/srv" = {
    directories = [
      "/var/lib/kubernetes"
      "/var/lib/etcd"
      "/var/lib/cfssl"
      "/var/lib/kubelet"

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
    # luks stuff
    "aes"
    "aesni_intel"
    "cryptd"
  ];

  boot.kernelModules = [ "kvm-amd" ];

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

  boot.initrd.secrets = {
    "/crypt.keyfile" = "/srv/secrets/initrd/crypt.keyfile";
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

    "/persist" = {
      device = "/srv";
      options = [ "bind" ];
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
}
