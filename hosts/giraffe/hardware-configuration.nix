{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "xhci_pci" "sd_mod" "sr_mod" "aes_x86_64" "aesni_intel" "cryptd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "elevator=none"
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    enableCryptodisk = true;
    zfsSupport = true;
  };

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/fcffe844-e187-4a05-bbf9-b92d5b5ae003";
      preLVM = true;
      allowDiscards = true;
    };
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-24 05:24:14 UTC";
  };

  fileSystems = {
    "/" =
      { device = "rpool/local/root";
      fsType = "zfs";
    };

    "/nix" =
      { device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/home/diego" =
      { device = "rpool/persist/home/diego";
      fsType = "zfs";
    };

    "/home/risson" =
      { device = "rpool/persist/home/risson";
      fsType = "zfs";
    };

    "/root" =
      { device = "rpool/persist/home/root";
      fsType = "zfs";
    };

    "/srv" =
      { device = "rpool/persist/srv";
      fsType = "zfs";
    };

    "/boot" =
      { device = "/dev/disk/by-uuid/91f628df-9ed7-47a4-bc4f-41225a65c0b5";
      fsType = "ext4";
    };
  };


  swapDevices = [];

  nix.maxJobs = 1;

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = "performance";
  };
}
