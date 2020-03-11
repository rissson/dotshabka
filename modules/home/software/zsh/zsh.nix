{ config, pkgs, lib, ... }:

with pkgs;
with lib;

let
  shabka = import <shabka> { };

  myFunctions = stdenvNoCC.mkDerivation rec {
    name = "zsh-functions-${version}";
    version = "0.0.1";
    src = ./plugins/functions;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir $out

      cp $src/* $out/

      rm -f $out/default.nix

      substituteInPlace $out/c \
        --subst-var-by archiver_bin ${getBin shabka.external.nixpkgs.release-unstable.archiver}/bin/arc

      substituteInPlace $out/gcim \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/gorder \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed

      substituteInPlace $out/gtime \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed

      substituteInPlace $out/get_pr \
        --subst-var-by curl_bin ${getBin curl}/bin/curl \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by jq_bin ${getBin jq}/bin/jq \
        --subst-var-by xsel_bin ${getBin xsel}/bin/xsel

      substituteInPlace $out/git_require_clean_work_tree \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/git_gopath_formatted_repo_path \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by perl_bin ${getBin perl}/bin/perl

      substituteInPlace $out/jsonpp \
        --subst-var-by python_bin ${getBin python37Full}/bin/python \
        --subst-var-by pygmentize_bin ${getBin python36Packages.pygments}/bin/pygmentize

      substituteInPlace $out/jspp \
        --subst-var-by js-beautify_bin ${getBin python36Packages.jsbeautifier}/bin/js-beautify

      substituteInPlace $out/kcc \
        --subst-var-by kubectl ${getBin kubectl}/bin/kubectl

      substituteInPlace $out/kcn \
        --subst-var-by kubectl ${getBin kubectl}/bin/kubectl

      substituteInPlace $out/new_pr \
        --subst-var-by curl_bin ${getBin curl}/bin/curl \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by jq_bin ${getBin jq}/bin/jq \
        --subst-var-by xsel_bin ${getBin xsel}/bin/xsel

      substituteInPlace $out/sapg \
        --subst-var-by apg_bin ${getBin apg}/bin/apg

      substituteInPlace $out/tmycli \
        --subst-var-by mycli_bin ${getBin mycli}/bin/mycli \
        --subst-var-by netstat_bin ${getBin nettools}/bin/netstat \
        --subst-var-by ssh_bin ${getBin openssh}/bin/ssh

      substituteInPlace $out/ulimit_usage \
        --subst-var-by paste_bin ${getBin coreutils}/bin/paste \
        --subst-var-by cut_bin ${getBin coreutils}/bin/cut \
        --subst-var-by awk_bin ${getBin gawk}/bin/awk \
        --subst-var-by lsof_bin ${getBin lsof}/bin/lsof \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed \
        --subst-var-by bc_bin ${getBin bc}/bin/bc

      substituteInPlace $out/pr \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/vim_clean_swap \
        --subst-var-by vim_bin ${getBin vim}/bin/vim

      substituteInPlace $out/x \
        --subst-var-by archiver_bin ${getBin shabka.external.nixpkgs.release-unstable.archiver}/bin/arc

      substituteInPlace $out/xmlpp \
        --subst-var-by xmllint_bin ${getBin libxml2Python}/bin/xmllint
    ''

    + lib.optionalString stdenv.isLinux ''
      substituteInPlace $out/mkfs.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
        --subst-var-by mkfs_ext2_bin ${getBin e2fsprogs}/bin/mkfs.ext2

      substituteInPlace $out/mount.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
        --subst-var-by lpass_bin ${getBin lastpass-cli}/bin/lpass

      substituteInPlace $out/umount.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup

      substituteInPlace $out/register_u2f \
        --subst-var-by pamu2fcfg_bin ${getBin pam_u2f}/bin/pamu2fcfg
    ''

    + lib.optionalString stdenv.isDarwin ''
      rm -f $out/mkfs.enc $out/mount.enc $out/umount.enc $out/register_u2f
    '';
  };
in {
  programs.zsh = mkForce (mkMerge [
    ({ initExtra = optionalString stdenv.isDarwin ''
      # source the nix profiles
      if [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';})

    {
      enable = true;

      # If a command is issued that can't be executed as a normal command, and the
      # command is the name of a directory, perform the cd command to that directory.
      # This option is only applicable if the option SHIN_STDIN is set, i.e. if
      # commands are being read from standard input. The option is designed for
      # interactive use; it is recommended that cd be used explicitly in scripts to
      # avoid ambiguity.
      autocd = true;

      shellAliases = {
        cat = "${bat}/bin/bat";
        e = "\${EDITOR:-nvim}";
        k = "kubectl";
        ll = mkForce "ls -lha";
        pw = "ps aux | grep -v grep | grep -e";
        rot13 = "tr \"[A-Za-z]\" \"[N-ZA-Mn-za-m]\"";
        serve_this = "${python3}/bin/python -m http.server";
        utf8test = "${curl}/bin/curl -L https://github.com/tmux/tmux/raw/master/tools/UTF-8-demo.txt";
        v = "nvim";
        vi = "nvim";
        vim = "nvim";

        # Always enable colored `grep` output
        # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        grep = "grep --color=auto";

        # use 'fc -El 1' for "dd.mm.yyyy"
        # use 'fc -il 1' for "yyyy-mm-dd"
        # use 'fc -fl 1' for mm/dd/yyyy
        history = "fc -il 1";
      };

      history = {
        expireDuplicatesFirst = true;
        save = 100000000;
        size = 1000000000;
      };

      initExtra = ''
        # source in the LS_COLORS
        source "${nur.repos.kalbasit.ls-colors}/ls-colors/bourne-shell.sh"
        '' + (builtins.readFile (substituteAll {
          src = ./init-extra.zsh;

          bat_bin      = "${getBin bat}/bin/bat";
          fortune_bin  = "${getBin fortune}/bin/fortune";
          fzf_bin      = "${getBin fzf}/bin/fzf-tmux";
          home_path    = "${config.home.homeDirectory}";
          jq_bin       = "${getBin jq}/bin/jq";
          less_bin     = "${getBin less}/bin/less";
          tput_bin     = "${getBin ncurses}/bin/tput";
        })) + ''
          if [ -z "$INSIDE_EMACS" ]; then
            eval "$(${pkgs.starship}/bin/starship init zsh)"
          fi
        '';

      oh-my-zsh = {
        enable = true;

        plugins = [
          "command-not-found"
          "git"
          "history"
          "sudo"
        ];
      };

      plugins = [
        {
          name = "enhancd";
          file = "init.sh";
          src = fetchFromGitHub {
            owner = "b4b4r07";
            repo = "enhancd";
            rev = "fd805158ea19d640f8e7713230532bc95d379ddc";
            sha256 = "0pc19dkp5qah2iv92pzrgfygq83vjq1i26ny97p8dw6hfgpyg04l";
          };
        }
        {
          name = "gitit";
          src = fetchFromGitHub {
            owner = "peterhurford";
            repo = "git-it-on.zsh";
            rev = "4827030e1ead6124e3e7c575c0dd375a9c6081a2";
            sha256 = "01xsqhygbxmv38vwfzvs7b16iq130d2r917a5dnx8l4aijx282j2";
          };
        }
        {
          name = "solarized-man";
          src = fetchFromGitHub {
            owner = "zlsun";
            repo = "solarized-man";
            rev = "a902b64696271efee95f37d45589078fdfbbddc5";
            sha256 = "04gm4qm17s49s6h9klbifgilxv8i45sz3rg521dwm599gl3fgmnv";
          };
        }
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
        {
          name = "functions";
          src = myFunctions;
        }
      ];
    }
  ]);

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
    };
  };
}
