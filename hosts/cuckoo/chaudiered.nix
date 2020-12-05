{ config, pkgs, lib, ... }:

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
        --subst-var-by imagemagick ${pkgs.imagemagick} \
        --subst-var-by curl ${pkgs.curl}
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

    preStart = ''
      mkdir -p ${htmlDir}
    '';

    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString chaudiered;
      EnvironmentFile = config.sops.secrets.chaudiered_env.path;
    };
  };

  sops.secrets.chaudiered_env.sopsFile = ./chaudiered.yml;

  networking.firewall.allowedTCPPorts = [ 80 ];
}
