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
      "/var/lib/docker"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  /*environment.etc."modprobe.d/zfs.conf".text = ''
    options zfs zfs_arc_max=2147483648
  '';*/

  boot.initrd.availableKernelModules = [
    "ahci"
    "ehci_pci"
    "sd_mod"
    "usb_storage"
    "usbhid"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/disk/by-id/ata-WDC_WD1600AAJS-75M0A0_WD-WMAV3C792830";
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

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

    "/home/diego" = {
      device = "rpool/persist/home/diego";
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

    "/storj/1" = {
      device = "/dev/disk/by-uuid/e156420b-b775-41ca-8ccb-87662449e081";
      fsType = "ext4";
    };

    "/storj/2" = {
      device = "/dev/disk/by-uuid/17d5d2c9-d82b-4003-b048-3c7480ff1f08";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/7911c38f-5ee5-439c-ba69-a57128ed90b3"; }
  ];
}
