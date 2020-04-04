# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
    zfsSupport = true;
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/ROOT/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/ROOT/home";
      fsType = "zfs";
    };

  fileSystems."/home/diego" =
    { device = "rpool/ROOT/home/diego";
      fsType = "zfs";
    };

  fileSystems."/home/risson" =
    { device = "rpool/ROOT/home/risson";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "rpool/ROOT/home/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/NIX/nix";
      fsType = "zfs";
    };

  fileSystems."/opt" =
    { device = "rpool/ROOT/opt";
      fsType = "zfs";
    };

  fileSystems."/srv" =
    { device = "rpool/ROOT/srv";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "rpool/ROOT/tmp";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "rpool/ROOT/var";
      fsType = "zfs";
    };

  fileSystems."/var/cache" =
    { device = "rpool/ROOT/var/cache";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    { device = "rpool/ROOT/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "rpool/ROOT/var/lib/docker";
      fsType = "zfs";
    };

  fileSystems."/var/lib/libvirt" =
    { device = "rpool/ROOT/var/lib/libvirt";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    { device = "rpool/ROOT/var/log";
      fsType = "zfs";
    };

  fileSystems."/var/spool" =
    { device = "rpool/ROOT/var/spool";
      fsType = "zfs";
    };

  fileSystems."/var/tmp" =
    { device = "rpool/ROOT/var/tmp";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "bpool/BOOT/boot";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/09a51cb0-eae7-4c25-826a-be99bf583106"; }
      { device = "/dev/disk/by-uuid/cf2e3dba-5687-4d63-987e-dde2056c8439"; }
      { device = "/dev/disk/by-uuid/9e875d9c-ce27-4ec5-b6a7-c534cd01914b"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
