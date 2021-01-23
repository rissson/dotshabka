{
  session_name = "cri-intranet";
  start_directory = "~/cri/services/intranet";
  windows = [
    {
      focus = true;
      layout = "main-horizontal";
      options = { main-pane-height = 45; };
      panes = [
        {
          focus = true;
          shell_command =
            "read && DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose up --build";
        }
        null
      ];
      window_name = "docker-compose";
    }
    {
      panes = [{ shell_command = "git status"; }];
      window_name = "git";
    }
    {
      panes = [{ shell_command = "\${EDITOR} ."; }];
      window_name = "editor";
    }
    {
      panes = [ null ];
      start_directory = "docker";
      window_name = "docker";
    }
  ];
}
