{ config, pkgs, lib, ... }:

{
    services.screen-locker.lockCmd = lib.mkForce "/home/risson/haltode.sh";
}
