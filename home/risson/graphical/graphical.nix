{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    lama-corp.graphical = mkEnableOption "Enable graphical softwares";
  };

  config = mkIf config.lama-corp.graphical {
    home.packages = with pkgs; [
      thunderbird
    ];

    services.random-background = {
      enable = true;
      enableXinerama = true;
      display = "center";
      imageDirectory = "%h/.background-images";
      interval = "1h";
    };
  };
}
