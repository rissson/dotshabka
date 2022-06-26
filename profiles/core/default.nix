{ inputs, mode, pkgs, lib, ... }:

let
  inherit (lib) mkMerge optionalAttrs optionals;

  packages = with pkgs; [
    bc
    file
    gnumake
    htop
    iftop
    inetutils
    iotop
    jq
    killall
    ldns
    lsof
    lshw
    mbuffer
    ncdu
    pciutils
    pv
    screen
    tcpdump
    tree
    unzip
    usbutils
    wget
    zip
  ] ++ (optionals (mode == "NixOS") [
    tcptraceroute
    traceroute
  ]);
in
{
  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "Europe/Paris";

      soxin = {
        settings = {
          keyboard = {
            layouts = lib.mkAfter (lib.singleton {
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

      console.font = "Lat2-Terminus16";

      nix = {
        systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

        distributedBuilds = true;

        autoOptimiseStore = true;
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 10d";
        };
        optimise.automatic = true;

        useSandbox = true;

        trustedUsers = [ "root" "@wheel" "@builders" ];

        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
          "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
          "nixpkgs-master=${inputs.nixpkgs-master}"
          "soxin=${inputs.soxin}"
          "soxincfg=${inputs.self}"
        ];

        binaryCaches = [
          "https://s3.lama-corp.space/cache.nix.lama-corp.space"
          "http://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"
        ];
        binaryCachePublicKeys = [
          "cache.nix.lama-corp.space:zXDtep4OcIi2/hkqNmA1UkAoDTGBZE/YvEQdT750L1M="
          "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="
        ];
      };

      system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

      security = {
        protectKernelImage = true;
      };

      environment.systemPackages = packages;
    })

    (optionalAttrs (mode == "home-manager") {
      home.packages = packages;
    })
  ];
}
