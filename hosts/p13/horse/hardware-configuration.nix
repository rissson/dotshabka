{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nix.maxJobs = 23;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "performance";
    powertop.enable = lib.mkForce false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/libvirt"

      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    # luks stuff
    "aes"
    "aesni_intel"
    "cryptd"
  ];

  boot.kernelModules = [ "kvm-amd" ];
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

  boot.initrd.secrets = {
    "/crypt.keyfile" = "/persist/secrets/initrd/crypt.keyfile";
  };

  boot.initrd.luks.devices = {
    cryptboot = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0T233824B-part2";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0T233824B-part3";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0T233824B-part4";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
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

    "/efi" = {
      device = "/dev/disk/by-uuid/580D-49D4";
      fsType = "vfat";
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

    "/var/lib/docker" = {
      device = "rpool/persist/docker";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ecdc99e4-1646-4a1d-bd4f-9e138340e080"; }
  ];
}
