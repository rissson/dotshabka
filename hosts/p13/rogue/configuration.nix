{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation

    ./hardware-configuration.nix
    ./networking
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  nix.gc.automatic = lib.mkForce false;
  /*nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "kvm-1.srv.fsn.lama-corp.space"; system = "x86_64-linux"; maxJobs = 2; speedFactor = 2; supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ]; }
  ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';*/

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
