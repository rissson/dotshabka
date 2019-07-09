{ config, pkgs, lib, ... }:

with lib;

with import <shabka/util>;

{
  config = mkIf config.shabka.workstation.enable {
    home = {
      packages = with pkgs; [
        thunderbird
      ];
    };
  };
}