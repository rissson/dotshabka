{ config, ... }:

let
  port = 25505;
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in
{
  imports = [
    "${impermanence}/nixos.nix"
  ];

  environment.persistence."/persist" = {
    directories = [
      config.services.minecraft-server.dataDir
      "/var/log"
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];
  nixpkgs.config.allowUnfree = true;

  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    serverProperties = {
      difficulty = "normal";
      force-gamemode = true;
      level-name = "epita-strasbourg-2022";
      max-players = 20;
      motd = "A Minecraft Server for EPITA Strasbourg 2022";
      online-mode = false;
      "query.port" = port;
      server-port = port;
      snooper-enabled = false;
      white-list = false;
    };
  };
}
