{
  session_name = "soxincfg";
  start_directory = "~/lama-corp/infra/dotshabka";
  windows = [
    {
      focus = true;
      panes = [ "git status" ];
      window_name = "git";
    }
    {
      panes = [ null ];
      window_name = "editor";
    }
    {
      panes = [ "nix flake show" ];
      window_name = "build";
    }
    {
      panes = [{
        shell_command =
          [ "echo export CF_TOKEN" "poetry install && poetry shell" ];
      }];
      start_directory = "~/lama-corp/infra/dns";
      window_name = "dns";
    }
  ];
}
