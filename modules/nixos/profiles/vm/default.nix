{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.vm;
in {
  options = {
    lama-corp.profiles.vm = {
      enable = mkEnableOption "Enable profile for VM hosts";
      vmType = mkOption {
        type = types.str;
        default = "";
        description = ''
          VM type depending on the host. Currently supported options are kvm-1.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    fileSystems = mkMerge [
      (optionalAttrs (cfg.vmType == "kvm-1") {
        "/" = {
          device = "lpool/root";
          fsType = "zfs";
        };
        "/nix" = {
          device = "lpool/nix";
          fsType = "zfs";
        };
        "/var/log" = {
          device = "lpool/var/log";
          fsType = "zfs";
        };
        "/root" = {
          device = "ppool/home/root";
          fsType = "zfs";
        };
        "/srv" = {
          device = "ppool/srv";
          fsType = "zfs";
        };
        "/boot" = {
          device = "/dev/disk/by-label/nixos-boot";
          fsType = "ext4";
        };
        "/efi" = {
          device = "/dev/disk/by-label/nixos-efi";
          fsType = "vfat";
        };
      })
    ];

    boot = mkIf (cfg.vmType == "kvm-1") {
      loader.grub.device = "/dev/vda";

      initrd.postDeviceCommands = mkAfter ''
        zfs rollback -r lpool/root@blank
      '';
    };
  };
}
