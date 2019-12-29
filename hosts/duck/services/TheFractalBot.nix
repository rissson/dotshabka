{ config, pkgs, lib, ... }:

let
  shabka = import <shabka> { };

in {
  systemd.services.TheFractalBot = {
    description = "FIXME";
    script = "exec ${shabka.external.risson.nur.brocoli}/bin/brocoli bot";
    startAt = "09:09";

    serviceConfig.User = "diego";
    serviceConfig.Group = "mine";
  };
}
