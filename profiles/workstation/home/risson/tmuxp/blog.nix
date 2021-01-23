{
  session_name = "blog";
  start_directory = "~/code/risson.space";
  windows = [
    {
      window_name = "hugo";
      panes = [
        {
          shell_command = "hugo server --disableFastRender --port 6562";
          focus = true;
        }
        null
      ];
    }
    {
      window_name = "git";
      focus = true;
      panes = [
        { shell_command = "git status"; }
        {
          shell_command = "read && rbrowser http://localhost:6562 && exit";
          focus = true;
        }
      ];
    }
    {
      window_name = "editor";
      start_directory = "content/posts";
      panes = [ "\${EDITOR} ." ];
    }
    {
      window_name = "smol theme";
      panes = [ null ];
      start_directory = "~/code/github/smol";
    }
  ];
}
