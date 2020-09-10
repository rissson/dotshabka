{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.nix;
in {
  options = {
    lama-corp.common.nix.enable = mkEnableOption "Enable common nix settings";
  };

  config = mkIf cfg.enable {
    nix = {
      autoOptimiseStore = true;
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 10d";
      };
    };
  };
}
