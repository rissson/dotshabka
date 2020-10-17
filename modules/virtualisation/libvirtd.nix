{ mode, config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.virtualisation.libvirtd;
in
{
  options = {
    lama-corp.virtualisation.libvirtd = {
      enable = mkEnableOption "Enable libvirtd.";
      addAdminUsersToGroup = recursiveUpdate (mkEnableOption ''
        Whether to add admin users declared in lama-corp.users to the
        `libvirtd` group.
      '') { default = true; };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      virtualisation.libvirtd = {
        enable = true;
        qemuRunAsRoot = false;
      };

      lama-corp.users.groups = optional cfg.addAdminUsersToGroup "libvirtd";
    })
  ]);
}
