{ pkgs, lib, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub = {
    configurationLimit = 30;
    device = "nodev";
    efiSupport = true;
    enable = true;
    enableCryptodisk = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.luks.devices = {
    cryptvgroot = {
      device = "/dev/disk/by-uuid/4463e27b-5bd1-4945-b4be-b5ea86ac46dd";
      preLVM = true;
      keyFile = "/keyfile0.bin";
      allowDiscards = true;
    };
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.extraInitrd = /boot/initrd.keys.gz;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5e2332dc-77c3-4b59-91d2-416b25f10e0e";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/CB1A-AC4D";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2ffe6dbb-ec89-444a-8d22-0277eb02b0c7";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9e42b003-dcee-4d78-a983-a278263916a9"; } ];

  nix.maxJobs = lib.mkDefault 8;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
