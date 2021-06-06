{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bind"
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
        "uhci_hcd"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
    };
    zfs.devNodes = "/dev/disk/by-path";
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
    };
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/1319e919-5dd9-43b5-9e89-3a6896da058d";
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
    { device = "/dev/disk/by-uuid/64d13dab-77d5-4c23-bcdf-e77a572d5380"; }
  ];
}
