{ config, pkgs, lib, ... }:

{
    services.screen-locker.lockCmd = lib.mkForce "${pkgs.i3lock-color}/bin/i3lock-color --clock --color=ffa500 --show-failed-attempts --bar-indicator --datestr='%A %Y-%m-%d'";
}