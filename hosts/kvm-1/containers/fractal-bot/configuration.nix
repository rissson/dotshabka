{ config, pkgs, lib, ... }:

let
  nixpkgs =
    import (import <shabka> { }).external.nixpkgs.release-unstable.path { };

  brocoli = with nixpkgs;
    python3Packages.buildPythonApplication rec {
      pname = "brocoli";
      version = "334d672d48b4f80f1f077b89deea079d2766e268";

      src = fetchFromGitLab {
        owner = "ddorn";
        repo = pname;
        rev = version;
        sha256 = "0cw8rsw40j6rkv8iiksnsap7r0krxxa0vx0akihcgxd51vwivg5k";
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
        python3Packages.pillow
      ];

      doCheck = false; # There are no tests.
    };

in {
  systemd.services.TheFractalBot = {
    description =
      "Brocoli, a bot that posts a new random fractal everyday on Twitter.";
    script = "exec ${brocoli}/bin/brocoli bot";
    startAt = "07:42";
    serviceConfig.EnvironmentFile = "/persist/secrets/TheFractalBot.service.env";
  };
}
