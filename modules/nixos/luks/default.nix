{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.luks;
in {
  options = {
    lama-corp.luks.enable = mkEnableOption "Enable default luks settings";
  };

  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules = [ "aes_x86_64" "aesni_intel" "aesni_amd" "cryptd" ];

    boot.loader.grub.enableCryptodisk = true;
  };
}
