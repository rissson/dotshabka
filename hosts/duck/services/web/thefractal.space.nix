{ lib, ... }:

with lib;

let
  thefractalspaceSrc = pkgs.fetchFromGitLab {
    owner = "ddorn";
    repo = "thefractal.space";
    rev = "FIXME";
    sha256 = "FIXME";
  };
  thefractalspace = import thefractalspaceSrc { };
  thefractalspaceEnv = import thefractalspaceSrc { mkEnv = true; };
  socketName = "uwsgi-thefractal.space.sock";
  socket = "${config.services.uwsgi.runDir}/${socketName}";
in {
  services.uwsgi.instance.vassals."thefractalspace" = {
    type = "normal";
    pyhome = "${thefractalspaceEnv}";
    env = [
      "PATH=${thefractalspace.python}/bin"
      "PYTHONPATH=${thefractalspace}/${thefractalspace.python.sitePackages}"
      "FRACTALS_DIR=/srv/http/thefractal.space"
    ];
    wsgi = "thefractalspace.app:app";
    inherit socket;
    chmod-socket = "664";
    master = true;
    processes = 2;
    vacuum = true;
  };

  services.nginx.virtualHosts."thefractal.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-thefractal.space.log netdata;
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
