{ nixos-hardware, lib, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-hdd
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
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  environment.etc."modprobe.d/zfs.conf".text = ''
    options zfs zfs_arc_max=2147483648
  '';

  boot.initrd.availableKernelModules = [
    "ehci_pci"
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
    devices = [
      "/dev/disk/by-id/ata-Hitachi_HDT721010SLA360_STF601MH09AM5B"
      "/dev/disk/by-id/ata-Hitachi_HDT721010SLA360_STF601MH07R6MB"
    ];
    enableCryptodisk = true;
    copyKernels = true;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.initrd.luks.devices = {
    cryptroot1.device = "/dev/disk/by-uuid/e759aaea-99dd-4ce4-8ec0-7dc5d4784729";
    cryptroot2.device = "/dev/disk/by-uuid/7c606d48-740a-4f8c-ad75-8d0d988e3463";
    cryptswap1.device = "/dev/disk/by-uuid/999f51e4-2b69-45a8-9828-d8b9ff572c49";
    cryptswap2.device = "/dev/disk/by-uuid/549ee3de-0384-4d4c-8e8e-6256d868d5d5";
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "bpool/boot/boot";
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

    "/persist" = {
      device = "rpool/persist/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/root" = {
      device = "rpool/persist/home/root";
      fsType = "zfs";
    };

    "/home/risson" = {
      device = "rpool/persist/home/risson";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/5487a618-0bb4-4c0d-b7ca-a3d8356b8222"; }
    { device = "/dev/disk/by-uuid/729bf2b0-7b01-4a70-908c-ec7085f5d2d5"; }
  ];
}
