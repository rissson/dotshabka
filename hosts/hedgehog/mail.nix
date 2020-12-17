{ config, pkgs, ... }:

let
  shutils = pkgs.fetchgit {
    url = "https://git.sthu.org/repos/shutils.git";
    rev = "b3eb33c68802db67fcc78437c96fb14d105fa308";
    sha256 = "13q1fx7man61f2qadwnm81r0pxxwhhva4frcy9856six8k0jnar8";
  };

  mailcap = pkgs.writeText "mailcap" ''
    text/html; ${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser %s
    application/pdf; ${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser %s
  '';

  muttGruvbox = "${shutils}/dotfiles/mutt/colors-gruvbox-shuber.muttrc";
  neomuttGruvBox = "${shutils}/dotfiles/mutt/colors-gruvbox-shuber-extended.muttrc";
in
{
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/mail";

    accounts = {
      epita = {
        realName = "Marc 'risson' Schmitt";
        address = "marc.schmitt@epita.fr";
        aliases = [
          "marc@cri.epita.fr"
          "risson@cri.epita.fr"
        ];
        signature = {
          showSignature = "append";
          text = import ./signature.nix {
            extraLines = ''
              Bon camarade du BL/GANG
              CRI - ACDC 2022
              EPITA
            '';
          };
        };

        flavor = "plain";
        folders = {
          inbox = "INBOX";
          sent = "Sent Items";
          trash = "Deleted Items";
        };
        userName = "marc.schmitt@epita.fr";
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/epita";
        imap = {
          host = "outlook.office365.com";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "outlook.office365.com";
          port = 587;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        msmtp.enable = true;
        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            mailboxes `find ${config.accounts.email.maildirBasePath}/epita -type d -name cur | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | sort | tr '\n' ' '`
          '';
        };
      };

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
        passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/lama-corp";
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
          create = "both";
          expunge = "both";
          remove = "both";
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            mailboxes `find ${config.accounts.email.maildirBasePath}/lama-corp -type d -name cur | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | sort | tr '\n' ' '`
          '';
        };
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

      pager_index_lines = "10";
      pager_context = "3";
      pager_stop = "yes";
      menu_scroll = "yes";
      tilde = "yes";

      send_charset = ''"utf-8:iso-8859-1:us-ascii"'';
      charset = ''"utf-8"'';

      mailcap_path = toString mailcap;
    };

    extraConfig = ''
      unset mime_forward
      ignore *
      unignore from: to: cc: bcc: date: subject:
      unhdr_order *
      hdr_order from: to: cc: bcc: date: subject:
      alternative_order text/plain text/enriched text/html
      auto_view text/html

      # some sane vim-like keybindings
      bind index,pager k previous-entry
      bind index,pager j next-entry
      bind index,pager g noop
      bind index,pager \Cu half-up
      bind index,pager \Cd half-down
      bind pager gg top
      bind index gg first-entry
      bind pager G bottom
      bind index G last-entry

      # Sidebar Navigation
      bind index,pager <pagedown> sidebar-next
      bind index,pager <pageup> sidebar-prev
      bind index,pager <right> sidebar-open

      source ${muttGruvbox}
      source ${neomuttGruvBox}
    '';
  };
}
