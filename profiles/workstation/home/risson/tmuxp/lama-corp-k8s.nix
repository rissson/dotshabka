{
  session_name = "lama-corp-k8s";
  start_directory = "~/lama-corp/infra/k8s";
  windows = [
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "argocd";
      window_name = "argocd";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "cluster/apps";
      window_name = "cluster apps";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "cluster/others";
      window_name = "cluster others";
    }
    {
      focus = true;
      panes = [ "git status" ];
      start_directory = "apps/manifests";
      window_name = "apps";
    }
    {
      panes = [ null ];
      window_name = "others";
    }
  ];
}
