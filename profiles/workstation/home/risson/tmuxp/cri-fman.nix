{
  session_name = "cri-fman";
  start_directory = "~/cri/services/fleet-manager";
  windows = [
    {
      focus = true;
      layout = "main-horizontal";
      options = { main-pane-height = 45; };
      panes = [
        {
          focus = true;
          shell_command =
            "read && DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose -p fman up --build";
        }
        null
      ];
      start_directory = "docker";
      window_name = "docker-compose";
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
    {
      panes = [{ shell_command = "git status"; }];
      window_name = "git";
    }
    {
      panes = [ null ];
      start_directory = "frontend";
      window_name = "frontend";
    }
  ];
}
