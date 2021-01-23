{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.tmux.tmuxp;
in
{
  options = {
    programs.tmux.tmuxp = {
      settings = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          tmuxp configuration
        '';
        example = {
          custom = {
            session_name = "custom";
          };
        };
      };
    };
  };

  config = optionalAttrs (mode == "home-manager") {
    xdg.configFile = mkIf cfg.enable (
      mapAttrs' (name: value: {
        name = "tmuxp/${name}.json";
        value.text = builtins.toJSON value;
      }) cfg.settings
    );
  };
}
