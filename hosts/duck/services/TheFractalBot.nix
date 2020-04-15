{ config, pkgs, lib, ... }:

let
  shabka = import <shabka> {};
  dotshabka = import ../../.. {};
  rissonNur = import dotshabka.external.risson.nur.path { pkgs = import shabka.external.nixpkgs.release-unstable.path {}; };
in {
  systemd.services.TheFractalBot = {
    description = "Brocoli, a bot that posts a new random fractal everyday on Twitter.";
    script = "exec ${rissonNur.brocoli}/bin/brocoli bot twitter";
    startAt = "07:42";

    serviceConfig.User = "diego";
    serviceConfig.Group = "mine";
  };
}
