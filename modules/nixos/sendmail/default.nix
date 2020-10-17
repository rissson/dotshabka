{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.sendmail;
in {
  options = {
    lama-corp.sendmail = {
      enable = mkEnableOption "Enable sendmail via postfix";
      recipientAddress = mkOption {
        type = types.str;
        default = "root@lama-corp.ovh";
      };
    };
  };

  config = mkIf cfg.enable {
    services.postfix = {
      enable = true;
      hostname = "lama-corp.space";
    };
  };
}
