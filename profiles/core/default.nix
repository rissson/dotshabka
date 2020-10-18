{ pkgs, lib, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  console = {
    earlySetup = lib.mkForce true;
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
  };

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

    binaryCaches = [
      "http://cache.nixos.org"
      "http://yl.cachix.org"
      "http://risson.cachix.org"
    ];

    binaryCachePublicKeys = [
      "yl.cachix.org-1:Abr5VClgHbNd2oszU+ivr+ujB0Jt2swLo2ddoeSMkm0="
      "risson.cachix.org-1:x5ge8Xn+YFlaEqQr3oHhMXxHPYSXbG2k2XFtGqGemwg="
    ];

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
}
