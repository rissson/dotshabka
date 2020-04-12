{ config, pkgs, lib, ... }:

with lib;

let
  bootHostSshKeyPath = /srv/secrets/root/initrd-ssh-key;
in {
  warnings = (optional (!(builtins.pathExists bootHostSshKeyPath))
    "${toString bootHostSshKeyPath} does not exists. You will not be able to decrypt the disks through SSH after a reboot."
  );

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    copyKernels = true;
    efiSupport = false;
    enableCryptodisk = true;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  boot.initrd.network = (mkIf (builtins.pathExists bootHostSshKeyPath) {
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
  });

  boot.initrd.luks.devices = [
    {
      name = "cryptroot";
      device = "/dev/disk/by-uuid/3573c5d2-11f6-45a2-8bf2-e325922b0cd5";
    }
    {
      name = "cryptswap1";
      device = "/dev/disk/by-uuid/b6e59cc1-1d1c-4a7f-9e9f-d89a9dc78935";
    }
    {
      name = "cryptswap2";
      device = "/dev/disk/by-uuid/a33a7cf1-5570-47ef-84eb-a79a6e49c533";
    }
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/338877a6-bcf3-40f2-8798-5683e000b531";
      fsType = "xfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/9f1cd2f9-74a0-4e26-ba27-e501d5bf3fc4";
      fsType = "xfs";
    };

  fileSystems."/opt" =
    { device = "/dev/disk/by-uuid/86b01e8a-2ee6-4185-896e-f4f3f372c7f6";
      fsType = "xfs";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/de013b18-da3b-4117-8b24-327a8ed45dfa";
      fsType = "xfs";
    };

  fileSystems."/srv" =
    { device = "/dev/disk/by-uuid/5a85ee5c-f351-4df8-915e-d773f51b582c";
      fsType = "xfs";
    };

  fileSystems."/var" =
    { device = "/dev/disk/by-uuid/4a975e48-a7be-451b-8628-22b1964c65b9";
      fsType = "xfs";
    };

  fileSystems."/home/diego" =
    { device = "/dev/disk/by-uuid/f3541147-07ab-41ac-98f3-c92d427c5282";
      fsType = "xfs";
    };

  fileSystems."/home/lewdax" =
    { device = "/dev/disk/by-uuid/56ff78f0-e33a-4c34-81fe-2905dff9b5de";
      fsType = "xfs";
    };

  fileSystems."/home/risson" =
    { device = "/dev/disk/by-uuid/e18ed6ce-b4d9-4a52-b0f3-9768faf6b4fd";
      fsType = "xfs";
    };

  fileSystems."/root" =
    { device = "/dev/disk/by-uuid/b8336303-a0ff-4c73-b063-4385800a5a8b";
      fsType = "xfs";
    };

  fileSystems."/var/cache" =
    { device = "/dev/disk/by-uuid/e0191f12-055b-4c74-a6cb-aa73c11f59ab";
      fsType = "xfs";
    };

  fileSystems."/var/lib" =
    { device = "/dev/disk/by-uuid/eecd78e1-74b3-4bef-9457-9a16926ebab0";
      fsType = "xfs";
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/c1423fff-57ae-4268-a182-c2015d4dfd90";
      fsType = "xfs";
    };

  fileSystems."/var/lib/libvirt" =
    { device = "/dev/disk/by-uuid/db4857e4-ff0b-4166-93f0-a1a8d059aee3";
      fsType = "xfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/0723674b-9834-466e-aa7a-6ff3aa646207";
      fsType = "xfs";
    };

  fileSystems."/var/lib/libvirt/images" =
    { device = "/dev/disk/by-uuid/8936a009-a2b5-4bb0-804f-a4e292d8bc1e";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5520d746-6155-4da0-9a04-dc5decca2e0f";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/222f1806-a087-462a-948c-68c6a5726661"; }
      { device = "/dev/disk/by-uuid/1ba67c78-35bd-44b0-9058-468db8e26cce"; }
    ];
}
