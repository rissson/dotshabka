{ config, lib, pkgs, ... }:

with lib;

let
  catcdcSrc = pkgs.fetchFromGitLab {
    owner = "risson-epita/ACDC";
    repo = "catcdc";
    rev = "1.0.0";
    sha256 = "027xbdhmf4198l8dxwgbbvb2330cpn5iai3935rcny8bvvfqy60w";
  };
  catcdc = import catcdcSrc { };
  catcdcEnv = import catcdcSrc { mkEnv = true; };
  socketName = "uwsgi-cats.acdc.risson.space.sock";
  socket = "${config.services.uwsgi.runDir}/${socketName}";
in {
  services.uwsgi.instance.vassals."catcdc" = {
    type = "normal";
    pyhome = "${catcdcEnv}";
    env = [
      "PATH=${catcdc.python}/bin"
      "PYTHONPATH=${catcdc}/${catcdc.python.sitePackages}"
    ];
    wsgi = "catcdc.wsgi:application";
    inherit socket;
    chmod-socket = "664";
    master = true;
    processes = 2;
    vacuum = true;
  };

  environment.etc."catcdc/settings.py" = {
    source = "/srv/secrets/uwsgi/catcdc.settings.py";
  };

  systemd.services.uwsgi.restartTriggers =
    [ config.environment.etc."catcdc/settings.py".source ];

  systemd.services."catcdc" = {
    description = "Init cAtCDC database and static files";
    before = [ "nginx.service" "uwsgi.service" ];
    requiredBy = [ "nginx.service" "uwsgi.service" ];
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

  services.nginx.virtualHosts."cats.acdc.epita.fr" = {
    serverAliases = [ "cats.acdc.risson.space" ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-cats.acdc.risson.space.log netdata;
    '';
    locations = {
      "/" = {
        extraConfig = ''
          uwsgi_pass unix:${socket};
          include ${config.services.nginx.package}/conf/uwsgi_params;
        '';
      };
    };
  };
}
