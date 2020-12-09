{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" "aes_x86_64" "aesni_intel" "cryptd" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "elevator=none"
    "i915.enable_fbc=1"
    "i015.enable_psr=2"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
  };

  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
   ];
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.bluetooth.enable = true;

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  services.blueman.enable = true;
  services.tlp.enable = true;
  services.fstrim.enable = true;

  boot.initrd.secrets = {
    "/crypt.keyfile" = "/srv/secrets/initrd/crypt.keyfile";
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
    cryptboot = {
      device = "/dev/disk/by-id/nvme-LENSE20256GMSP34MEAT2TA_FBFB17124EJ0001919-part2";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
    cryptroot = {
      device = "/dev/disk/by-id/nvme-LENSE20256GMSP34MEAT2TA_FBFB17124EJ0001919-part4";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
    cryptswap = {
      device = "/dev/disk/by-id/nvme-LENSE20256GMSP34MEAT2TA_FBFB17124EJ0001919-part3";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/crypt.keyfile";
    };
};

  fileSystems."/" =
    { device = "rpool/local/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    { device = "rpool/local/var/log";
      fsType = "zfs";
    };

  fileSystems."/home/diego" =
    { device = "rpool/persist/home/diego";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "rpool/persist/home/root";
      fsType = "zfs";
    };

  fileSystems."/srv" =
    { device = "rpool/persist/srv";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "bpool/boot";
      fsType = "zfs";
    };

  fileSystems."/efi" =
    { device = "/dev/disk/by-uuid/AB78-7E0D";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/577320e6-1807-47c2-ad52-56fb6b93effb"; }
    ];

  nix.maxJobs = 7;
  powerManagement.cpuFreqGovernor = lib.mkForce "ondemand";
  powerManagement.enable = true;
}
