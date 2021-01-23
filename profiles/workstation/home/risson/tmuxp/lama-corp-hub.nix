{
  session_name = "lama-corp-hub";
  start_directory = "~/lama-corp/infra/services/hub";
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
