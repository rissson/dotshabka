{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    # inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  nix.maxJobs = 7;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "ondemand";
    powertop.enable = lib.mkForce false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/kubernetes"
      "/var/lib/etcd"
      "/var/lib/cfssl"
      "/var/lib/kubelet"

      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/fprint"
      "/var/lib/libvirt"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "nvme"
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
    "/crypt.keyfile" = "/persist/secrets/initrd/crypt.keyfile";
  };*/

  boot.initrd.luks.devices = {
    cryptboot = {
      device = "/dev/disk/by-id/nvme-KXG6AZNV512G_TOSHIBA_Z04F763IF2F3-part5";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/nvme-KXG6AZNV512G_TOSHIBA_Z04F763IF2F3-part6";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/nvme-KXG6AZNV512G_TOSHIBA_Z04F763IF2F3-part7";
      preLVM = true;
      allowDiscards = true;
      # keyFile = "/crypt.keyfile";
    };
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
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

    "/boot" = {
      device = "bpool/boot";
      fsType = "zfs";
    };

    "/efi" = {
      device = "/dev/disk/by-uuid/F045-B526";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/183083e3-984d-4db8-ad81-496b42d0ee0d"; }
  ];
}
