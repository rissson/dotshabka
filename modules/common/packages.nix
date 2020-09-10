{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.common.packages;
in {
  options = {
    lama-corp.common.packages.enable = mkEnableOption "Install common packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      htop
      iotop
      jq
      killall
      ldns
      minio-client
      ncdu
      tcpdump
      traceroute
      tree
      unzip
      wget
      zip
    ];
  };
}
