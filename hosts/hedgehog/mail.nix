{ config, pkgs, ... }:

let
  shutils = pkgs.fetchgit {
    url = "https://git.sthu.org/repos/shutils.git";
    rev = "b3eb33c68802db67fcc78437c96fb14d105fa308";
    sha256 = "13q1fx7man61f2qadwnm81r0pxxwhhva4frcy9856six8k0jnar8";
  };

  muttGruvbox = "${shutils}/dotfiles/mutt/colors-gruvbox-shuber.muttrc";
  neomuttGruvBox = "${shutils}/dotfiles/mutt/colors-gruvbox-shuber-extended.muttrc";
in
{
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/mail";

    accounts = {
      lama-corp = {
        primary = true;
        realName = "Marc 'risson' Schmitt";
        address = "risson@lama-corp.space";
        aliases = [
          "marc.schmitt@lama-corp.space"
          "marc.schmitt@risson.space"
          "risson@risson.space"
        ];
        signature = {
          showSignature = "append";
          text = import ./signature.nix {
            extraLines = ''
              Lama Corp.
            '';
          };
        };

        flavor = "plain";
        folders.inbox = "INBOX";
        userName = "risson";
        passwordCommand = "cat /home/risson/.secrets/mail/lama-corp";
        imap = {
          host = "mail.lama-corp.space";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "mail.lama-corp.space";
          port = 587;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        msmtp.enable = true;
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";
          remove = "none";
        };
        neomutt.enable = true;
      };
    };
  };

  /*programs.astroid = {
    enable = true;
    externalEditor = "nvim -- -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1";
  };*/

  programs.msmtp = {
    enable = true;
  };

  programs.mbsync = {
    enable = true;
  };
  services.mbsync = {
    enable = true;
  };

  programs.neomutt = {
    enable = true;
    editor = "$EDITOR '+set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %s";

    sort = "date";
    checkStatsInterval = 600;

    sidebar = {
      enable = true;
      shortPath = true;
      width = 50;
    };

    settings = {
      sidebar_delim_chars = ''"/"'';
      sidebar_folder_indent = "yes";
      sidebar_indent_string = ''"  "'';

      timeout = "3";
      mail_check = "600";
      delete = "yes";
      mark_old = "no";

      edit_headers = "yes";
      fast_reply = "yes";
      forward_format = ''"Fwd: %s"'';
      reply_to = "yes";
      reverse_name = "yes";
      forward_quote = "yes";
      text_flowed = "yes";

      status_chars = ''" *%A"'';
      status_format = ''"[ Folder: %f ] [%r%m messages%?n? (%n new)?%?d? (%d to delete)?%?t? (%t tagged)? ]%>─%?p?( %p postponed )?"'';
      date_format = ''"%Y/%m/%d %H:%M"'';
      index_format = ''"%4C %Z %D %-15.15L (%?l?%4l&%4c?) %s"'';

      pager_index_lines = "5";
      pager_context = "3";
      pager_stop = "yes";
      menu_scroll = "yes";
      tilde = "yes";

      send_charset = ''"utf-8:iso-8859-1:us-ascii"'';
      charset = ''"utf-8"'';
    };

    extraConfig = ''
      mailboxes `find ${config.accounts.email.maildirBasePath} -type d -name cur | sort | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | tr '\n' ' '`

      source ${muttGruvbox}
      source ${neomuttGruvBox}
    '';
  };
}
