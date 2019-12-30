{ config, pkgs, lib, ... }:

{
  systemd.services.TheFractalBot = {
    description = "FIXME";
    script = "exec ${pkgs.nur.repos.risson.brocoli}/bin/brocoli bot";
    startAt = "09:09";

    serviceConfig.User = "diego";
    serviceConfig.Group = "mine";
  };
}
