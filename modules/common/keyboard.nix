{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.keyboard;
in {
  options = {
    lama-corp.common.keyboard.enable = mkEnableOption "Enable keyboard common settings";
  };

  config = mkIf cfg.enable {
    shabka.keyboard.layouts = [ "qwerty" ];
    shabka.keyboard.enableAtBoot = true;
  };
}
