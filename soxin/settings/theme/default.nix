{ lib, ... }:

with lib;

{
  soxin.settings.theme = "gruvbox-dark";

  imports = [
    ./gruvbox
  ];
}
