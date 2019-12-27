{ config, pkgs, lib, ... }:

with lib;
with pkgs;

{
  programs.zsh = {
    enable = true;

    # If a command is issued that can't be executed as a normal command, and the
    # command is the name of a directory, perform the cd command to that directory.
    # This option is only applicable if the option SHIN_STDIN is set, i.e. if
    # commands are being read from standard input. The option is designed for
    # interactive use; it is recommended that cd be used explicitly in scripts to
    # avoid ambiguity.
    autocd = true;

    enableCompletion = true;
    enableAutosuggestions = true;

    shellAliases = mkForce {
      cat = "${bat}/bin/bat";
      e = "\${EDITOR:-nvim}";
      ll = mkForce "ls -lha";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      execsw1 = "sudo ip netns exec sw1";
      execsw2 = "sudo ip netns exec sw2";
      exechost1 = "sudo ip netns exec host1";
      exechost2 = "sudo ip netns exec host2";
      exechost3 = "sudo ip netns exec host3";
      exechost11 = "sudo ip netns exec host11";
      exechost12 = "sudo ip netns exec host12";
      exechost13 = "sudo ip netns exec host13";

      # Always enable colored `grep` output
      # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
    };

    initExtra = mkForce (''
      function upload () # This should be cleaned, but later... TODO
      {
        # Main variables
        SSH_USER="risson"
        SSH_HOST="duck.lama-corp.space"
        SSH="$SSH_USER@$SSH_HOST"
        HTTP_SERVER_PATH="/home/risson/upload"
        BASE_URL="https://upload.risson.space"

        # Parse arguments
        if [ $# -lt 2 ]; then
          echo "At least two arguments are needed"
          return -1
        fi
        FILES=$*[0,-2]
        ADD_PATH=$*[-1]

        # Upload files
        echo "Uploading $FILES..."
        rsync --partial --progress --archive $FILES $SSH:$HTTP_SERVER_PATH/$ADD_PATH
        err=$?
        if [ $err -ne 0 ]; then
          echo "Error while uploading, aborting!"
          return $err
        fi
        unset err

        # Correct file permission on the server
        echo "Fixing permissions..."
        for file in $FILES; do
          ssh -q -t $SSH chmod -R +r "$HTTP_SERVER_PATH/$ADD_PATH/`basename $file`"
        done

        # Prompt links to uploaded files
        for file in $FILES; do
          echo $BASE_URL/$ADD_PATH/`basename $file`
        done
      }
    '' + (builtins.readFile (substituteAll {
        src = ./init-extra.zsh;

        bat_bin      = "${getBin bat}/bin/bat";
        fortune_bin  = "${getBin fortune}/bin/fortune";
        fzf_bin      = "${getBin fzf}/bin/fzf-tmux";
        home_path    = "${config.home.homeDirectory}";
        jq_bin       = "${getBin jq}/bin/jq";
        less_bin     = "${getBin less}/bin/less";
        tput_bin     = "${getBin ncurses}/bin/tput";
      })));
  };
}
