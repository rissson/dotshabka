{ mode, soxincfg, config, lib, pkgs, modulesPath, ... }:

with lib;

let
  cfg = config.lama-corp.virtualisation.libvirtd;
in
{
  options = {
    lama-corp.virtualisation = {
      libvirtd = {
        enable = mkEnableOption "libvirtd";
        images = mkOption {
          default = [];
          type = with types; listOf (enum [ "nixos" ]);
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      soxin.virtualisation.libvirtd.enable = true;
    }

    (optionalAttrs (mode == "NixOS") {
      environment.etc = listToAttrs (map (image: nameValuePair ("libvirtd/base-images/${image}.qcow2") (
        if image == "nixos" then {
          source = "${import ./nixos-image.nix { inherit soxincfg pkgs modulesPath; system = "x86_64-linux"; }}/image.qcow2";
        }
        else {}
      )) cfg.images);
    })
  ]);
}
