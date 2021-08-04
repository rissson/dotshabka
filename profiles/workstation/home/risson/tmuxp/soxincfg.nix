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
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "k3s/argocd";
      window_name = "argocd";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "k3s/cluster/apps";
      window_name = "cluster apps";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "k3s/cluster/others";
      window_name = "cluster others";
    }
    {
      panes = [ "git status" ];
      start_directory = "k3s/apps";
      window_name = "apps";
    }
  ];
}
