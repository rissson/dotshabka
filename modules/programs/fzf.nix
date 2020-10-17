{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.lama-corp.programs.fzf;
in
{
  options = {
    lama-corp.programs.fzf = {
      enable = mkEnableOption "Whether to enable fzf, a command-line fuzzy finder.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      programs.fzf = {
        enable = true;
        defaultCommand = ''(${pkgs.git}/bin/git ls-tree -r --name-only HEAD || ${pkgs.silver-searcher}/bin/ag --hidden --ignore .git -g "")'';
      };
    })
  ]);
}
