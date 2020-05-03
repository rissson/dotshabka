{ config, lib, pkgs, ... }:

with lib;

let bootHostSshKeyPath = /srv/secrets/root/initrd-ssh-key;
in {
  warnings = (optional (!(builtins.pathExists bootHostSshKeyPath)) "${
      toString bootHostSshKeyPath
    } does not exists. You will not be able to decrypt the disks through SSH after a reboot.");

  imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "virtio_pci"
    "xhci_pci"
    "sd_mod"
    "sr_mod"
    "aes_x86_64"
    "aesni_intel"
    "cryptd"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "elevator=none" ];

  boot.initrd.postDeviceCommands = mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

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

  boot.initrd.network = mkIf (builtins.pathExists bootHostSshKeyPath) {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostECDSAKey = bootHostSshKeyPath;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-24 05:24:14 UTC";
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/root" = {
      device = "rpool/persist/home/root";
      fsType = "zfs";
    };

    "/srv" = {
      device = "rpool/persist/srv";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/91f628df-9ed7-47a4-bc4f-41225a65c0b5";
      fsType = "ext4";
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/dd184cf2-21db-486b-a810-37991b6586eb"; }];

  nix.maxJobs = 1;

  powerManagement = mkIf config.shabka.workstation.power.enable {
    cpuFreqGovernor = "performance";
  };
}
