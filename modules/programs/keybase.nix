{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.programs.keybase;
in
{
  options = {
    lama-corp.programs.keybase = {
      enable = mkEnableOption "Whether to enable Keybase.";
      enableFs = mkEnableOption "Whether to enable Keybase filesystem.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.keybase.enable = true;
      services.kbfs.enable = cfg.enableFs;
    }
  ]);
}
