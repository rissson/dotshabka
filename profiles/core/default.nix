{ mode, pkgs, lib, nixpkgs, nixpkgsUnstable, nixpkgsMaster, soxin, self, ... }:

with lib;

{
  config = mkMerge [
    {
      soxin = {
        settings = {
          keyboard = {
            layouts = mkAfter (singleton {
              x11 = {
                layout = "us";
                variant = "";
              };
              console.keyMap = "us";
            });
            enableAtBoot = true;
          };
        };

        hardware.enable = true;
      };
    }

    (optionalAttrs (mode == "NixOS" || mode == "Darwin") {
      nix = {
        useSandbox = pkgs.stdenv.hostPlatform.isLinux;
        nixPath = [
          "nixpkgs=${nixpkgs.path}"
          "nixpkgs-unstable=${nixpkgsUnstable.path}"
          "nixpkgs-master=${nixpkgsMaster.path}"
          "soxin=${soxin.path}"
          "soxincfg=${self.path}"
        ];

        systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

        distributedBuilds = true;

        autoOptimiseStore = true;
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 10d";
        };
        optimise.automatic = true;

        trustedUsers = [ "root" "@wheel" "@builders" ];
      };

      environment.systemPackages = with pkgs; [
        htop
        iftop
        iotop
        jq
        killall
        ldns
        ncdu
        tcpdump
        telnet
        traceroute
        tree
        unzip
        wget
        zip
      ];
    })

    (optionalAttrs (mode == "NixOS") {
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "Europe/Paris";

      boot.kernelPackages = pkgs.linuxPackages;
      console.font = "Lat2-Terminus16";

      security.protectKernelImage = true;

      system.configurationRevision = lib.mkIf (self ? rev) self.rev;
    })
  ];
}
