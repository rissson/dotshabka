{ config, pkgs, lib, ... }:

{
  systemd.services.TheFractalBot = {
    description = "Brocoli, a bot that posts a new random fractal everyday on Twitter.";
    script = "exec ${pkgs.nur.repos.risson.brocoli}/bin/brocoli bot";
    startAt = "07:42";

    serviceConfig.User = "diego";
    serviceConfig.Group = "mine";
  };
}
