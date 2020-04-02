{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4dbca2d3-6086-4e8e-9f18-71b5917329b2";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/93d4365f-e967-49fc-8ac7-10da7370b620"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
}
