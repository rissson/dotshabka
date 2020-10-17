{ mode, config, pkgs, lib, ... }:

with lib;
let
  cfg = config.lama-corp.services.openssh;
in
{
  options = {
    lama-corp.services.openssh = {
      enable = mkEnableOption ''
        Whether to enable the OpenSSH secure shell daemon, which allows secure
        remote logins.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      services.openssh = {
        enable = true;
        passwordAuthentication = false;
        extraConfig = ''
          StreamLocalBindUnlink yes
        '';
      };
    })
  ]);
}
