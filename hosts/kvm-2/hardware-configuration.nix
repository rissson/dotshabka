{ config, lib, ... }:

{
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib/libvirt"
      "/var/lib/netdata"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "igb"
        "nvme"
        "sd_mod"
        "aes_x86_64"
        "aesni_amd"
        "cryptd"
      ];

      luks.devices = {
        cryptroot1.device = "/dev/disk/by-uuid/5c459e4c-3e12-4c73-a531-2f010c12b822";
        cryptroot2.device = "/dev/disk/by-uuid/ddc35067-a0cf-44ac-9514-3bf273c2109d";
      };

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            "/persist/secrets/initrd/ssh_host_rsa_key"
            "/persist/secrets/initrd/ssh_host_ed25519_key"
          ];
          authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
        };
        postCommands = ''
          echo 'cryptsetup-askpass' >> /root/.profile
        '';
      };

      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r rpool/local/root@blank
      '';
    };

    kernelParams = [
      "elevator=none"
    ];
    kernelModules = [ "kvm-amd" ];

    loader = {
      grub = {
        enable = true;
        version = 2;
        devices = [
          "/dev/disk/by-id/ata-HGST_HUH721008ALE600_4DGD3BBZ"
          "/dev/disk/by-id/ata-HGST_HUH721008ALE600_4DG59J1Z"
        ];
        enableCryptodisk = true;
        copyKernels = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "bpool/boot";
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

    "/home/diego" = {
      device = "rpool/persist/home/diego";
      fsType = "zfs";
    };

    "/home/risson" = {
      device = "rpool/persist/home/risson";
      fsType = "zfs";
    };

    "/persist" = {
      device = "rpool/persist/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  nix.maxJobs = 10;

  powerManagement.cpuFreqGovernor = "performance";
}
