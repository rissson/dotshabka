{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./mattermost
    ./web
  ] ++ (optionals (builtins.pathExists "${<dotshabka>}/secrets")
    (singleton "${<dotshabka>}/secrets"));
}
