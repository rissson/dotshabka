{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.lama-corp.programs.mosh;
in
{
  options = {
    lama-corp.programs.mosh = {
      enable = mkEnableOption ''
        Whether to enable mosh.
        On NixOS, this installs mosh and opens ports 60000 to 61000 in your
        firewall.
        On home-manager, this only install mosh.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      programs.mosh = {
        enable = true;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      home.packages = [ pkgs.mosh ];
    })
  ]);
}
