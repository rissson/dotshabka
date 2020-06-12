{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.lama-corp.graphical {
    gtk = mkForce {
      enable = true;
      font = {
        package = pkgs.hack-font;
        name = "xft:SourceCodePro:style:Regular:size=9:antialias=true";
      };
      iconTheme = {
        package = pkgs.arc-icon-theme;
        name = "Arc";
      };
      theme = {
        package = pkgs.arc-theme;
        name = "Arc-dark";
      };
    };
  };
}
