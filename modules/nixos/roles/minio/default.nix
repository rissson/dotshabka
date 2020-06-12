{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.minio;
in {
  options = {
    lama-corp.minio = {
      enable = mkEnableOption "Enable minio";

      stateDir = mkOption {
        type = types.str;
        default = "/srv/minio";
      };

      port = mkOption {
        type = types.int;
        default = 19000;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    services.minio = {
      enable = false; # Enabled by secrets
      listenAddress = ":${toString cfg.port}";
      configDir = "${cfg.stateDir}/config";
      dataDir = "${cfg.stateDir}/data";
    };
  };
}
