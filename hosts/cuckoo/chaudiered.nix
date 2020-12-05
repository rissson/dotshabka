{ pkgs, lib, ... }:

let
  htmlDir = "/var/www/html/";

  chaudiered = pkgs.stdenv.mkDerivation {
    name = "chaudiered";
    phases = [ "installPhase" "fixupPhase" ];
    src = ./chaudiered.sh;
    installPhase = ''
      install -D -m755 $src $out
      substituteInPlace $out \
        --subst-var-by htmlDir ${htmlDir} \
        --subst-var-by coreutils ${pkgs.coreutils} \
        --subst-var-by fswebcam ${pkgs.fswebcam} \
        --subst-var-by imagemagick ${pkgs.imagemagick}
    '';
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      root = htmlDir;
    };
  };

  systemd.services.chaudiered = {
    description = "Monitoring the fucking boiler.";

    startAt = "*:*:0,30"; # every 30 seconds

    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString chaudiered;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
