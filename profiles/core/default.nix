{ pkgs, lib, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    package = pkgs.nixFlakes;
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

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

  security = {
    hideProcessInformation = true;
    protectKernelImage = true;
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
}
