{
  session_name = "cri-k8s";
  start_directory = "~/cri/infra/k8s";
  windows = [
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "argocd";
      window_name = "argocd";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "clusters/apps";
      window_name = "cluster apps";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "clusters/others";
      window_name = "cluster others";
    }
    {
      focus = true;
      panes = [ "git status" ];
      start_directory = "cri/manifests";
      window_name = "apps";
    }
    {
      window_name = "others";
    }
  ];
}
