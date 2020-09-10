{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.boot;
in {
  options = {
    lama-corp.common.boot.enable = mkEnableOption "Enable grub with default settings";
  };

  config = mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      version = 2;
    };
  };
}
