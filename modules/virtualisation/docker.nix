{ mode, config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.virtualisation.docker;
in
{
  options = {
    lama-corp.virtualisation.docker = {
      enable = mkEnableOption "Enable docker.";
      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in lama-corp.users to the `docker`
        group.
      '') { default = true; };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      virtualisation.docker = {
        enable = true;
      };

      lama-corp.users.groups = optional cfg.addAdminUsersToGroup "docker";
    })
  ]);
}
