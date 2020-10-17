{ mode, config, lib, ... }:

with lib;

{
  options = {
    lama-corp.hardware = {
      enable = mkEnableOption "Enable default hardware settings";
    };
  };

  config = mkIf config.lama-corp.hardware.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.fwupd.enable = true;
    })
  ]);
}
