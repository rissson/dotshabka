{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bind"
      "/var/lib/knot"
      "/var/lib/netdata"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "ehci_pci"
        "sr_mod"
        "uhci_hcd"
        "virtio_blk"
        "virtio_pci"
      ];
    };
    zfs.devNodes = "/dev/disk/by-path";
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
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

    "/boot" = {
      device = "/dev/disk/by-uuid/05749994-60be-47f6-bb3b-8cbab88d1e27";
      fsType = "ext4";
    };

    "/etc" = {
      device = "rpool/local/etc";
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
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/093ea8e5-f796-4e57-a6d7-0c0938c7ef85"; }
  ];
}
