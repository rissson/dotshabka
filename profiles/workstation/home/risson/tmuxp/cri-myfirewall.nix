{
  session_name = "myfirewall";
  start_directory = "~/cri/recruitement/2023-myfirewall";
  windows = [
    {
      focus = true;
      panes = [ "git status" ];
      window_name = "git";
    }
    {
      panes = [ "\${EDITOR} ." ];
      start_directory = "src";
      window_name = "editor";
    }
    {
      panes = [
        {
          focus = true;
          shell_command = "make -B";
        }
        {
          shell_command = [
            "read && sudo ip netns exec nsfw ./myfirewall -c config myfw-in-nsfw myfw-out-nsfw"
          ];
        }
      ];
      window_name = "build";
    }
    {
      panes = [
        {
          focus = true;
          shell_command = [ "ip netns exec nsin iperf -s" "read && sudo -i" ];
        }
        {
          shell_command =
            [ "ip netns exec nsout iperf -c fd00::" "read && sudo -i" ];
        }
      ];
      window_name = "iperf";
    }
  ];
}
