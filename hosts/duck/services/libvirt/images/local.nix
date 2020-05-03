{ config, pkgs, system, extraConfig, ... }:

let
  vmTools = pkgs.callPackage "${pkgs.path}/pkgs/build-support/vm" {
    kernel = config.system.modulesTree.override { name = "kernel-modules"; };
    rootModules = [
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_balloon"
      "virtio_rng"
      "ext4"
      "unix"
      "9p"
      "9pnet_virtio"
      "crc32c_generic"
      "zfs"
      "spl"
    ];
  };

  config = (import <nixpkgs/nixos/lib/eval-config.nix> {
    inherit system;
    modules = [
      {
        imports = [
          <dotshabka/modules/nixos/server/ssh.nix>
          <dotshabka/modules/nixos/server/users.nix>
        ];

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "virtio_balloon"
          "virtio_blk"
          "virtio_pci"
          "virtio_ring"
          "aes_x86_64"
          "aesni_intel"
          "cryptd"
        ];
        boot.supportedFilesystems = [ "zfs" ];
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.kernelParams = [ "elevator=none" ];

        boot.loader.grub = {
          enable = true;
          version = 2;
          device = "/dev/vda";
          zfsSupport = true;
        };

        fileSystems = {
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
        };

        # We want our template image to be as small as possible, but the deployed
        # image should be able to beof any size. Hence we resize on the first boot
        systemd.services.resize-main-fs = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            # Resize main partition to fill the whole disk
            echo ", +" | ${pkgs.utillinux}/bin/sfdisk /dev/vda --no-reread -N 4
            echo ", +" | ${pkgs.utillinux}/bin/sfdisk /dev/vdb --no-reread
            ${pkgs.parted}/bin/partprobe
          '';
        };
      }

      extraConfig
    ];
  }).config;

in vmTools.runInLinuxVM (pkgs.runCommand "libvirt-guest-image-local" {
  memSize = 768;
  preVM = ''
    mkdir $out
    diskImage=image.qcow2
    ${pkgs.vmTools.qemu}/bin/qemu-img create -f qcow2 $diskImage 5G
    mv closure xchg/
  '';
  postVM = ''
    echo compressing VM image...
    ${pkgs.vmTools.qemu}/bin/qemu-img convert -c $diskImage -O qcow2 $out/image.qcow2
  '';

  buildInputs = with pkgs; [ utillinux perl gptfdisk zfs e2fsprogs dosfstools ];
  exportReferencesGraph = [ "closure" config.system.build.toplevel ];
} ''
  echo creating partitions...
  # Default disk for QEMU
  DISK=/dev/vda

  # Partition 1 will be the boot partition, needed for legacy (BIOS) boot
  sgdisk -a1 -n1:24K:+1000K -t1:EF02 $DISK
  # Partition 2 will be for UEFI booting (for future use)
  sgdisk     -n2:1M:+512M   -t2:EF00 $DISK
  # Partition 3 will be for the /boot partition, it's not worth creating a
  # special pool for it
  sgdisk     -n3:0:+1G      -t3:BF01 $DISK
  # Partition 4 will be the main ZFS partition, using up the rest of the disk
  sgdisk     -n4:0:0        -t4:BF01 $DISK

  # Boot partitions
  mkfs.vfat -n nixos-efi "$DISK"2
  mkfs.ext4 -L nixos-boot "$DISK"3

  # Create the zfs pool
  zpool create -o ashift=12 -O acltype=posixacl -O canmount=off \
    -O compression=on -O dnodesize=auto -O normalization=formD \
    -O relatime=on -O xattr=sa -O mountpoint=none \
    lpool "$DISK"4

  # Create the non-persistent zfs vols
  zfs create -o atime=off -o mountpoint=legacy lpool/nix
  zfs create -o mountpoint=legacy lpool/root
  zfs snapshot lpool/root@blank
  zfs create -o mountpoint=none lpool/var
  zfs create -o mountpoint=legacy lpool/var/log

  echo mounting partitions...
  # Mount the previously created partitions
  mkdir /mnt
  mount -t zfs lpool/root /mnt
  mkdir -p /mnt/{boot,efi,nix,var/log}
  mount "$DISK"3 /mnt/boot
  mount "$DISK"2 /mnt/efi
  mount -t zfs lpool/nix /mnt/nix
  mount -t zfs lpool/var/log /mnt/var/log

  for dir in dev proc sys; do
      mkdir /mnt/$dir
      mount --bind /$dir /mnt/$dir
  done

  storePaths=$(perl ${pkgs.pathsFromGraph} /tmp/xchg/closure)
  echo filling Nix store...
  mkdir -p /mnt/nix/store
  set -f
  cp -prd $storePaths /mnt/nix/store
  # The permissions will be set up incorrectly if the host machine is not
  # running NixOS
  chown -R 0:30000 /mnt/nix/store

  mkdir -p /mnt/etc/nix
  echo 'build-users-group = ' > /mnt/etc/nix/nix.conf

  # Ensures tools requiring /etc/passwd will work (e.g. nix)
  if [ ! -e /mnt/etc/passwd ]; then
    echo "root:x:0:0:System administrator:/root:/bin/sh" > /mnt/etc/passwd
  fi

  # Register the paths in the Nix database.
  printRegistration=1 perl ${pkgs.pathsFromGraph} /tmp/xchg/closure | \
      chroot /mnt ${config.nix.package.out}/bin/nix-store --load-db

  # Create the system profile to allow nixos-rebuild to work.
  chroot /mnt ${config.nix.package.out}/bin/nix-env \
      -p /nix/var/nix/profiles/system --set ${config.system.build.toplevel}

  # `nixos-rebuild' requires an /etc/NIXOS.
  mkdir -p /mnt/etc/nixos
  touch /mnt/etc/NIXOS

  # `switch-to-configuration' requires a /bin/sh
  mkdir -p /mnt/bin
  ln -s ${config.system.build.binsh}/bin/sh /mnt/bin/sh

  echo installing GRUB...
  # Generate the GRUB menu.
  chroot /mnt ${config.system.build.toplevel}/activate
  chroot /mnt ${config.system.build.toplevel}/bin/switch-to-configuration boot
'')
