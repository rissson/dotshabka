{ config, pkgs, lib, ... }:

with lib;

let
  serviceBuilder = args:
    import ./services ({
      inherit config pkgs lib;
      system = builtins.currentSystem;
    } // args);
  ynhServiceBuilder = args:
    import ./services/ynh.nix ({ inherit pkgs lib; } // args);

in {
  shabka.virtualisation.libvirtd.enable = true;

  systemd.services = {
    libvirtd-guest-acdc-tp14-1 =
      serviceBuilder (import ./guests/acdc-tp14-1.nix { inherit pkgs; });
    libvirtd-guest-ldap-1 =
      serviceBuilder (import ./guests/ldap-1.nix { inherit pkgs; });
    libvirtd-guest-mail-1 =
      serviceBuilder (import ./guests/mail-1.nix { inherit pkgs; });
    libvirtd-guest-minio-1 =
      serviceBuilder (import ./guests/minio-1.nix { inherit pkgs; });
    libvirtd-guest-postgres-1 =
      serviceBuilder (import ./guests/postgres-1.nix { inherit pkgs; });
    libvirtd-guest-reverse-1 =
      serviceBuilder (import ./guests/reverse-1.nix { inherit pkgs; });
    libvirtd-guest-web-1 =
      serviceBuilder (import ./guests/web-1.nix { inherit pkgs; });
    libvirtd-guest-web-2 =
      serviceBuilder (import ./guests/web-2.nix { inherit pkgs; });

    libvirtd-guest-lewdax-ynh =
      ynhServiceBuilder (import ./guests/lewdax-ynh.nix { inherit pkgs; });
    libvirtd-guest-lamacorp-ynh =
      ynhServiceBuilder (import ./guests/lamacorp-ynh.nix { inherit pkgs; });
  };
}
