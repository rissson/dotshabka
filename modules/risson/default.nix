{ lib, ... }:

with lib;

with import <shabka/util>;

{
  imports = recImport ./.;

  options = {
    lama-corp.graphical = mkEnableOption "Enable graphical softwares";
  };
}
