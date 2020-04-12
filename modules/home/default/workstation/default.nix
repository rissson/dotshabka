{ config, pkgs, lib, ... }:

with lib;

with import <shabka/util>;

{
  config = mkIf config.shabka.workstation.enable {
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
