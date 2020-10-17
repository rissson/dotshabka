{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.uwsgi;

  buildCfg = name: c:
    let
      plugins = if any (n: !any (m: m == n) cfg.plugins) (c.plugins or [ ]) then
        throw
        "`plugins` attribute in UWSGI configuration contains plugins not in config.services.uwsgi.plugins"
      else
        c.plugins or cfg.plugins;

      hasPython = v: filter (n: n == "python${v}") plugins != [ ];
      hasPython2 = hasPython "2";
      hasPython3 = hasPython "3";

      python = if hasPython2 && hasPython3 then
        throw
        "`plugins` attribute in UWSGI configuration shouldn't contain both python2 and python3"
      else if hasPython2 then
        cfg.package.python2
      else if hasPython3 then
        cfg.package.python3
      else
        null;

      pythonEnv = python.withPackages (c.pythonPackages or (self: [ ]));

      uwsgiCfg = {
        uwsgi = if c.type == "normal" then
          {
            inherit plugins;
          } // optionalAttrs (python != null) {
            pyhome = "${pythonEnv}";
            env =
              # Argh, uwsgi expects list of key-values there instead of a dictionary.
              let
                env' = c.env or [ ];
                getPath = x:
                  if hasPrefix "PATH=" x then
                    substring (stringLength "PATH=") (stringLength x) x
                  else
                    null;
                oldPaths = filter (x: x != null) (map getPath env');
              in env' ++ [
                "PATH=${
                  optionalString (oldPaths != [ ]) "${last oldPaths}:"
                }${pythonEnv}/bin"
              ];
          } // removeAttrs c [ "type" "pythonPackages" ]
        else if c.type == "emperor" then
          {
            emperor = pkgs.buildEnv {
              name = "vassals";
              paths = mapAttrsToList buildCfg c.vassals;
            };
          } // removeAttrs c [ "type" "vassals" ]
        else
          throw
          "`type` attribute in UWSGI configuration should be either 'normal' or 'emperor'";
      };

    in pkgs.writeTextDir "${name}.json" (builtins.toJSON uwsgiCfg);

in {

  options = {
    services.uwsgi = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable uWSGI";
      };

      runDir = mkOption {
        type = types.path;
        default = "/run/uwsgi";
        description = "Where uWSGI communication sockets can live";
      };

      package = mkOption {
        type = types.package;
        internal = true;
      };

      instance = {
        type = mkOption {
          type = types.str;
          default = "normal";
        };
        vassals = mkOption {
          type = types.attrs;
          default = { };
        };
      };

      plugins = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Plugins used with uWSGI";
      };

      user = mkOption {
        type = types.str;
        default = "uwsgi";
        description = "User account under which uwsgi runs.";
      };

      group = mkOption {
        type = types.str;
        default = "uwsgi";
        description = "Group account under which uwsgi runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.uwsgi = {
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.runDir}
        chown ${cfg.user}:${cfg.group} ${cfg.runDir}
      '';
      serviceConfig = {
        Type = "notify";
        ExecStart =
          "${cfg.package}/bin/uwsgi --uid ${cfg.user} --gid ${cfg.group} --json ${
            buildCfg "server" cfg.instance
          }/server.json";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        NotifyAccess = "main";
        KillSignal = "SIGQUIT";
      };
    };

    users.users = optionalAttrs (cfg.user == "uwsgi") {
      uwsgi = {
        group = cfg.group;
        uid = config.ids.uids.uwsgi;
      };
    };

    users.groups = optionalAttrs (cfg.group == "uwsgi") {
      uwsgi.gid = config.ids.gids.uwsgi;
    };

    services.uwsgi.package = pkgs.uwsgi.override { inherit (cfg) plugins; };
  };
}