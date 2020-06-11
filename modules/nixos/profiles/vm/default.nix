{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.vm;
in {
  options = {
    lama-corp.profiles.vm = {
      enable = mkEnableOption "Enable profile for VM hosts";
      vmType = mkOption {
        type = types.str;
        default = "";
        description = ''
          VM type depending on the host. Currently supported options are kvm-1
          and hetzner.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
  };
}
