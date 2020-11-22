{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  soxin.hardware.sound.enable = true;

  soxin.users = {
    enable = true;
    users = {
      risson = {
        inherit (soxincfg.vars.users.risson) uid hashedPassword sshKeys;
        isAdmin = true;
        home = "/home/risson";
      };
    };
  };

  hardware.pulseaudio = {
    systemWide = true;
    tcp = {
      enable = true;
      anonymousClients = {
        allowAll = true;
        allowedIpRanges = [ "172.28.2.0/24" ];
      };
    };
    zeroconf.publish.enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 4713 ];

  services.spotifyd = {
    enable = true;
    config = ''
      [global]
      backend = pulseaudio
      volume_controller = softvol

      no_audio_cache = false

      device_name = cuckoo
      device_type = speaker

      username = marcschmitt2@gmail.com
    '';
  };

  console.keyMap = lib.mkForce "us";

  users.users.root = {
    hashedPassword = "$6$qVi/b8BggEoVLgu$V0Mcqu73FWm3djDT4JwflTgK6iMxgxtFBs2m2R.zg1RukAXIcplI.MddMS5SNEhwAThoKCsFQG7D6Q2pXFohr0";
    openssh.authorizedKeys.keys = config.soxin.users.users.risson.sshKeys;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/srv/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
      {
        type = "ed25519";
        path = "/srv/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
