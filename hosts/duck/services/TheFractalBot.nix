{ config, pkgs, lib, ... }:

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};

  brocoli = with nixpkgs; python3Packages.buildPythonApplication rec {
    pname = "brocoli";
    version = "9c2cdb07df1802527bce502fad6f036b55efc65f";

    src = fetchFromGitLab {
      owner = "ddorn";
      repo = pname;
      rev = version;
      sha256 = "08dddy7hwrqjy0584bwyy151j3537n91015sxw74dyps51nk4gsg";
    };

    propagatedBuildInputs = [
      python3Packages.numpy
      python3Packages.numba
      python3Packages.colour
      python3Packages.tweepy
      python3Packages.click
      python3Packages.docutils
      python3Packages.pygments
      python3Packages.setuptools
      python3Packages.setuptools_scm
    ];

    doCheck = false; # There are no tests.
  };

in {
  systemd.services.TheFractalBot = {
    description = "Brocoli, a bot that posts a new random fractal everyday on Twitter.";
    script = "exec ${brocoli}/bin/brocoli bot";
    startAt = "07:42";

    serviceConfig.User = "diego";
    serviceConfig.Group = "mine";
  };
}
