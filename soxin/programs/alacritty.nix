{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.soxin.programs.alacritty;
in
{
  options = {
    soxin.programs.alacritty = {
      enable = mkEnableOption "Whether to enable alacritty.";

      transparency = mkEnableOption "Enable transparency on alacritty.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            opacity = if cfg.transparency then 0.3 else 1;
          };
          scolling = {
            history = 1000000;
          };
          font = {
            size = 9.5;
          };
          cursor = {
            style = {
              shape = "Beam";
            };
          };
          bell = {
            duration = 1;
          };
          mouse = {
            hide_when_typing = true;
          };
        };
      };
    })
  ]);
}
