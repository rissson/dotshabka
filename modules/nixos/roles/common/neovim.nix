{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.neovim;
in {
  options = {
    lama-corp.common.neovim.enable = mkEnableOption "Enable common neovim settings";
  };

  config = mkIf cfg.enable {
    shabka.neovim.enable = true;
  };
}
