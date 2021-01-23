{
  session_name = "cri-blog";
  start_directory = "~/cri/services/blog";
  windows = [
    {
      window_name = "hugo";
      panes = [
        {
          shell_command = "hugo server --disableFastRender --port 17138";
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
          shell_command = "read && rbrowser http://localhost:17138 && exit";
          focus = true;
        }
      ];
    }
    {
      window_name = "editor";
      start_directory = "content";
      panes = [ "\${EDITOR} ." ];
    }
  ];
}
