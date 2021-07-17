{ soxincfg, config, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.zfs

    ./hardware-configuration.nix
    ./networking
  ];

  lama-corp.virtualisation.libvirtd.enable = lib.mkForce false;

  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = [ pkgs.vim ];

  networking.firewall = {
    allowedTCPPorts = [ 28967 28968 14001 14002 ];
    allowedUDPPorts = [ 28967 28968 ];
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
  };

  virtualisation.oci-containers.containers = {
    storagenode1 = {
      image = "storjlabs/storagenode:latest";
      ports = [
        "28967:28967/tcp"
        "28967:28967/udp"
        "14001:14002"
      ];
      environment = {
        WALLET = "0x630a16Af200B9986dE849c1e5375fdc02B531406";
        EMAIL = "root@lama-corp.space";
        ADDRESS = "p13.lama.tel:28967";
        STORAGE = "0.90TB";
      };
      extraOptions = [
        "--stop-timeout=300"
        "--mount=type=bind,source=/persist/storj/1/identity,destination=/app/identity"
        "--mount=type=bind,source=/storj/1,destination=/app/config"
      ];
    };

    storagenode2 = {
      image = "storjlabs/storagenode:latest";
      ports = [
        "28968:28967/tcp"
        "28968:28967/udp"
        "14002:14002"
      ];
      environment = {
        WALLET = "0x630a16Af200B9986dE849c1e5375fdc02B531406";
        EMAIL = "root@lama-corp.space";
        ADDRESS = "p13.lama.tel:28968";
        STORAGE = "0.90TB";
      };
      extraOptions = [
        "--stop-timeout=300"
        "--mount=type=bind,source=/persist/storj/2/identity,destination=/app/identity"
        "--mount=type=bind,source=/storj/2,destination=/app/config"
      ];
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?
}
