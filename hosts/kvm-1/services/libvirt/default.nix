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
  ynhServiceBuilder = args:
    import ./services/ynh.nix ({ inherit pkgs lib; } // args);

in {
  shabka.virtualisation.libvirtd.enable = true;

  systemd.services = {
    libvirtd-guest-minio-1 =
      serviceBuilder (import ./guests/minio-1.nix { inherit pkgs; });
    libvirtd-guest-postgres-1 =
      serviceBuilder (import ./guests/postgres-1.nix { inherit pkgs; });

    libvirtd-guest-lewdax-ynh =
      ynhServiceBuilder (import ./guests/lewdax-ynh.nix { inherit pkgs; });
    libvirtd-guest-lamacorp-ynh =
      ynhServiceBuilder (import ./guests/lamacorp-ynh.nix { inherit pkgs; });
  };
}
