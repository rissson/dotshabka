{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common;
in {
  options = {
    lama-corp.common.enable = mkEnableOption "Enable all options under lama-corp.common";
  };

  imports = [
    <shabka/modules/nixos>
  ];

  config = mkIf cfg.enable {
    environment.homeBinInPath = true;

    lama-corp.common = {
      backups.enable = true;
      boot.enable = true;
      kernel.enable = true;
      keyboard.enable = true;
      locale.enable = true;
      neovim.enable = true;
      nix.enable = true;
      packages.enable = true;
      users.enable = true;
    };
  };
}
