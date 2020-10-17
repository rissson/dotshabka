{ config, lib, pkgs, ... }:

with lib;

let
  port = 8005;

  catcdcSrc = pkgs.fetchFromGitLab {
    owner = "risson-epita/ACDC";
    repo = "catcdc";
    rev = "1.0.0";
    sha256 = "027xbdhmf4198l8dxwgbbvb2330cpn5iai3935rcny8bvvfqy60w";
  };
  catcdc = import catcdcSrc { };
  catcdcEnv = import catcdcSrc { mkEnv = true; };
in {
  networking.firewall.allowedTCPPorts = [ port ];

  services.uwsgi.instance.vassals = {
    "catcdc" = {
      type = "normal";
      pyhome = "${catcdcEnv}";
      env = [
        "PATH=${catcdc.python}/bin"
        "PYTHONPATH=${catcdc}/${catcdc.python.sitePackages}"
      ];
      wsgi = "catcdc.wsgi:application";
      socket = ":${toString port}";
      master = true;
      processes = 2;
      vacuum = true;
    };
  };

  environment.etc."catcdc/settings.py" = {
    source = "/persist/secrets/uwsgi/cats.acdc.risson.space.settings.py";
  };

  systemd.services.uwsgi.restartTriggers =
    [ config.environment.etc."catcdc/settings.py".source ];

  systemd.services."catcdc" = {
    description = "Init cAtCDC database and static files";
    before = [ "uwsgi.service" ];
    requiredBy = [ "uwsgi.service" ];
    restartTriggers = [ config.environment.etc."catcdc/settings.py".source ];
    script = ''
      ${catcdc}/bin/catcdc migrate
      ${catcdc}/bin/catcdc collectstatic --no-input
    '';
    serviceConfig = {
      User = config.services.uwsgi.user;
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };
}
