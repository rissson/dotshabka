{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  boot.loader.grub = {
    copyKernels = true;
    mirroredBoots = [
      {
        devices = [ "/dev/disk/by-id/ata-ST33000650NS_Z293WSP6" ];
        path = "/boot-1";
      }
      {
        devices = [ "/dev/disk/by-id/ata-ST33000650NS_Z297P5M5" ];
        path = "/boot-2";
      }
    ];
  };

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostECDSAKey = /srv/keys/initrd-ssh-key;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
    };
    postCommands = ''
      zpool import -f tank
      echo "zfs load-key -a; killall zfs" >> /root.profile
    '';
  };

  fileSystems."/" =
    { device = "tank/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "tank/home";
      fsType = "zfs";
    };

  fileSystems."/opt" =
    { device = "tank/opt";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "tank/root/nix";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "tank/root/tmp";
      fsType = "zfs";
    };

  fileSystems."/srv" =
    { device = "tank/srv";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "tank/var";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "tank/home/root";
      fsType = "zfs";
    };

  fileSystems."/home/risson" =
    { device = "tank/home/risson";
      fsType = "zfs";
    };

  fileSystems."/home/diego" =
    { device = "tank/home/diego";
      fsType = "zfs";
    };

  fileSystems."/home/lewdax" =
    { device = "tank/home/lewdax";
      fsType = "zfs";
    };

  fileSystems."/var/cache" =
    { device = "tank/var/cache";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    { device = "tank/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    { device = "tank/var/log";
      fsType = "zfs";
    };

  fileSystems."/var/spool" =
    { device = "tank/var/spool";
      fsType = "zfs";
    };

  fileSystems."/var/tmp" =
    { device = "tank/var/tmp";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "tank/var/lib/docker";
      fsType = "zfs";
    };

  fileSystems."/var/lib/libvirt" =
    { device = "tank/var/lib/libvirt";
      fsType = "zfs";
    };

  fileSystems."/var/lib/libvirt/images" =
    { device = "tank/var/lib/libvirt/images";
      fsType = "zfs";
    };

  fileSystems."/boot-1" =
    { device = "/dev/disk/by-uuid/a24554b8-fe66-49a3-8a8b-db570e052066";
      fsType = "ext4";
    };

  fileSystems."/boot-2" =
    { device = "/dev/disk/by-uuid/b6b3dd50-60cc-4df2-b955-72cc78086c19";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0d96b773-1f2d-4191-a981-9e183ebe75c2"; }
      { device = "/dev/disk/by-uuid/0cb529e9-c3ff-47a7-a833-4355e77c7132"; }
    ];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "Sun, 03:23";
    };
    autoSnapshot = {
      enable = true;
      frequent = 8; # Every 15 minutes
      hourly = 24;
      daily = 7;
      weekly = 5;
      monthly = 12;
      flags = "-k -p -u"; # Do empty snapshots, in parallel, use UTC time for naming
    };
  };
}
