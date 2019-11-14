{ config, pkgs, lib, ... }:

with lib;
with pkgs;

{
  programs.zsh = mkForce {
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

    shellAliases = {
      cat = "${bat}/bin/bat";
      e = "\${EDITOR:-nvim}";
      ll = "ls -lha";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      # Always enable colored `grep` output
      # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
    };

    initExtra = ''
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
    '';

    history = {
      expireDuplicatesFirst = true;
      save = 100000000;
      size = 1000000000;
    };

    oh-my-zsh = {
      enable = true;

      plugins = [
        "command-not-found"
        "git"
        "sudo"
      ];
    };

    plugins = [
      {
        name = "zsh-completions";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.27.0";
          sha256 = "1c2xx9bkkvyy0c6aq9vv3fjw7snlm0m5bjygfk5391qgjpvchd29";
        };
      }

      {
        name = "zsh-history-substring-search";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "47a7d416c652a109f6e8856081abc042b50125f4";
          sha256 = "1mvilqivq0qlsvx2rqn6xkxyf9yf4wj8r85qrxizkf0biyzyy4hl";
        };
      }

      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
          sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
        };
      }

      {
        name = "nix-shell";
        src = fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "03a1487655c96a17c00e8c81efdd8555829715f8";
          sha256 = "1avnmkjh0zh6wmm87njprna1zy4fb7cpzcp8q7y03nw3aq22q4ms";
        };
      }
    ];
  };
}
