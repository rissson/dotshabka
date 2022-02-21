{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.workstation
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking
  ];

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "hybrid-sleep";
    extraConfig = ''
        HandlePowerKey=suspend
    '';
  };
  services.tlp.enable = lib.mkForce false;

  nix.gc.automatic = lib.mkForce false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}
