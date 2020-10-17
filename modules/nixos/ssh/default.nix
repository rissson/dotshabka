{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.ssh;
in {
  options = {
    lama-corp.ssh = {
      enable = mkEnableOption "Enable ssh";
      stateDir = mkOption {
        type = types.str;
        default = "/srv/ssh";
      };
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "prohibit-password";
      hostKeys = [
        {
          type = "rsa";
          bits = 4096;
          path = "${cfg.stateDir}/ssh_host_rsa_key";
          rounds = 100;
          openSSHFormat = true;
          comment = with config.networking; "${hostName}.${domain}";
        }
        {
          type = "ed25519";
          path = "${cfg.stateDir}/ssh_host_ed25519_key";
          rounds = 100;
          openSSHFormat = true;
          comment = with config.networking; "${hostName}.${domain}";
        }
      ];
    };

    systemd.services.sshd.preStart = mkIf config.services.openssh.enable
    (mkBefore ''
      mkdir -m 0700 -p ${cfg.stateDir}
    '');
  };
}
