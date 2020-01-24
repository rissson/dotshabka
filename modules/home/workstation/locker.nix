{ config, pkgs, lib, ... }:

{
    services.screen-locker.lockCmd = lib.mkForce "/home/risson/.lock-images/lock.sh";
}
