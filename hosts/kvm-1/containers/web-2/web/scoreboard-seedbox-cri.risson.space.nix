{ config, lib, pkgs, ... }:

with lib;

let
  port = 8004;
  scoreboardSrc = pkgs.fetchFromGitLab {
    owner = "risson-epita";
    repo = "scoreboard-seedbox-cri";
    rev = "1.1.1";
    sha256 = "0jrkwn5b46hisczmrz26xl7igh5vj4nx7xchms2i7avvh15zvgls";
  };
  scoreboard = import scoreboardSrc { };
  scoreboardEnv = import scoreboardSrc { mkEnv = true; };
in {
  networking.firewall.allowedTCPPorts = [ port ];

  services.uwsgi.instance.vassals = {
    "scoreboard_seedbox_cri" = {
      type = "normal";
      pyhome = "${scoreboardEnv}";
      env = [
        "PATH=${scoreboard.python}/bin"
        "PYTHONPATH=${scoreboard}/${scoreboard.python.sitePackages}"
      ];
      wsgi = "scoreboard_seedbox_cri.wsgi:application";
      socket = ":${toString port}";
      master = true;
      processes = 2;
      vacuum = true;
    };
  };

  environment.etc."scoreboard_seedbox_cri/settings.py" = {
    source = "/persist/secrets/uwsgi/scoreboard-seedbox-cri.risson.space.settings.py";
  };

  systemd.services.uwsgi.restartTriggers =
    [ config.environment.etc."scoreboard_seedbox_cri/settings.py".source ];

  systemd.services."scoreboard_seedbox_cri" = {
    description = "Init scoreboard database and static files";
    before = [ "uwsgi.service" ];
    requiredBy = [ "uwsgi.service" ];
    restartTriggers = [ config.environment.etc."scoreboard_seedbox_cri/settings.py".source ];
    script = ''
      ${scoreboard}/bin/scoreboard_seedbox_cri migrate
      ${scoreboard}/bin/scoreboard_seedbox_cri collectstatic --no-input
    '';
    serviceConfig = {
      User = config.services.uwsgi.user;
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };
}
