{ config, pkgs, lib, ... }:

with lib;

let
  serviceBuilder = args:
    import ./services/deployed.nix ({
      inherit config pkgs lib;
      system = builtins.currentSystem;
    } // args);
  toBeDeployedServiceBuilder = args:
    import ./services/to-be-deployed.nix ({
      inherit config pkgs lib;
      system = builtins.currentSystem;
    } // args);

in {
  shabka.virtualisation.libvirtd.enable = true;

  systemd.services = {
    libvirtd-guest-k8s-master-11 =
      toBeDeployedServiceBuilder (import ./guests/k8s-master-11.nix { inherit pkgs; });
  };
}
