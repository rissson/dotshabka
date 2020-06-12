{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.locale;
in {
  options = {
    lama-corp.common.locale.enable = mkEnableOption "Enable common locale settings";
  };

  config = mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    console.font = "Lat2-Terminus16";
    time.timeZone = "Europe/Paris";
  };
}
