{ config, lib, ... }:

with lib;

{
  boot.initrd.availableKernelModules = [ "aes_x86_64" "aesni_intel" "cryptd" ];

  boot.loader.grub.enableCryptodisk = true;
}
