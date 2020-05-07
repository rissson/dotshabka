{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 3000 3456 ];

  shabka.virtualisation.docker.enable = true;

  environment.etc."acdc-tp14/docker-compose.yml" = {
    source = ./docker-compose.yml;
  };

  systemd.services."acdc-tp14-docker-compose" = {
    description = "ACDC's TP14 moulinette";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      WorkingDirectory = "/etc/acdc-tp14";
    };

    path = with pkgs; [ docker-compose ];

    preStart = ''
      docker-compose pull --quiet
    '';

    script = ''
      docker-compose up -d
    '';

    preStop = ''
      docker-compose down
    '';

    reload = ''
      docker-compose pull --quiet
      docker-compose up -d
    '';

    reloadIfChanged = true;

    restartTriggers = [
      "/etc/acdc-tp14/docker-compose.yml"
    ];
  };
}
