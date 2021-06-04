{ mode, config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.soxin.programs.starship.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.starship = {
        settings = {
          add_newline = false;
          kubernetes = {
            disabled = false;
          };
        };
      };
    })
  ]);
}
