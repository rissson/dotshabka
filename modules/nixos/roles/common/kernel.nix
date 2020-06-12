{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.kernel;
in {
  options = {
    lama-corp.common.kernel.enable = mkEnableOption "Enable default kernel settings";
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
