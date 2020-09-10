{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.server;
in {
  options = {
    lama-corp.profiles.server.enable = mkEnableOption "Enable profile for server hosts";
  };

  config = mkIf cfg.enable {
    lama-corp.common.enable = true;
    lama-corp.netdata.enable = true;
    lama-corp.ssh.enable = true;
    lama-corp.zfs.enable = true;

    powerManagement.cpuFreqGovernor = "performance";
  };
}
