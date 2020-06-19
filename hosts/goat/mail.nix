{ config, pkgs, lib, ... }:

with lib;

let
  commonEmailAccount = {
    realName = "Marc 'risson' Schmitt";
    signature = {
      showSignature = "append";
      text = mkBefore ''
        Marc 'risson' Schmitt
      '';
    };
    gpg = {
      key = "marc.schmitt@risson.space";
      encryptByDefault = false;
      signByDefault = true;
    };

    imap = {
      port = 993;
      tls = { enable = true; };
    };
    smtp = {
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };

    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      remove = "both";
    };
    msmtp.enable = true;
    astroid.enable = true;
    notmuch.enable = true;
    #neomutt.enable = true;
  };

  gmailEmailAccount = { flavor = "gmail.com"; };

  myAccounts = {
    lamacorp = {
      address = "marc.schmitt@lama-corp.space";
      aliases = [ "risson@lama-corp.space" "marc.schmitt@risson.space" ];
      primary = true;
      signature.text = ''
        Lama Corp.
      '';

      userName = "risson";
      passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/lamacorp.passwd";

      smtp.host = "hub.lama-corp.space";
      imap.host = "hub.lama-corp.space";
      folders.inbox = "INBOX";
    };

    gmail = gmailEmailAccount // rec {
      address = "marcschmitt2@gmail.com";
      passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/gmail.passwd";
    };

    ojs = gmailEmailAccount // rec {
      address = "marc.schmitt@ojssymphonique.net";
      passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/ojs.passwd";
      signature.text = ''
        Orchestre symphonique des Jeunes de Strasbourg
      '';
    };

    prologin = gmailEmailAccount // rec {
      address = "marc.schmitt@prologin.org";
      passwordCommand = "${pkgs.coreutils}/bin/cat /home/risson/.secrets/mail/prologin.passwd";
      signature.text = ''
        EPITA 2022
        Prologin
      '';
    };
  };

  extendAccounts = name: value:
    nameValuePair name (commonEmailAccount // value);
in {
  accounts.email.maildirBasePath = "mail";
  accounts.email.accounts = mapAttrs' extendAccounts myAccounts;

  programs.msmtp.enable = true;

  programs.mbsync.enable = true;
  services.mbsync.enable = true;

  programs.astroid = {
    enable = true;
    externalEditor = ''
      ${pkgs.rxvt_unicode}/bin/urxvt -title email -e nvim -c '+set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1
     '';
  };

  programs.notmuch = {
    enable = true;
    new.tags = [ "new" "inbox" "unread" ];
    extraConfig = {
      search = {
        exclude_tags = "deleted;spam;killed";
      };
    };
    hooks = {
      postNew = ''
        notmuch tag -new -- tag:new
      '';
    };
  };

  /*programs.neomutt = {
    enable = true;
    editor =
      "$EDITOR '+set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %s";
    sort = "date";
    checkStatsInterval = 300;
    sidebar = {
      enable = true;
      format = "%B %* [%?N?%N / ?%S]";
      width = 80;
      shortPath = true;
    };
    settings = {
      sidebar_delim_chars = ''"/"'';
      sidebar_folder_indent = "yes";
      sidebar_indent_string = ''"  "'';

      wait_key = "no";
      timeout = "3";
      mail_check = "60";
      delete = "yes";
      quit = "yes";
      thorough_search = "yes";
      confirmappend = "no";
      move = "no";
      mark_old = "no";
      beep_new = "no";

      edit_headers = "yes";
      fast_reply = "yes";
      forward_format = ''"Fwd: %s"'';
      reply_to = "yes";
      reverse_name = "yes";
      forward_quote = "yes";
      text_flowed = "yes";

      status_chars = ''" *%A"'';
      status_format = ''"[ Folder: %f ] [%r%m messages%?n? (%n new)?%?d? (%d to delete)?%?t? (%t tagged)? ]%>─%?p?( %p postponed )?"'';
      date_format = ''"%d.%m.%Y %H:%M"'';
      index_format = ''"[%Z] %?X?A&-? %D  %-20.20F  %s"'';
      sort_re = "yes";
      reply_regexp = ''"^(([Rr][Ee]?(\[[0-9]+\])?: *)?(\[[^]]+\] *)?)*"'';
      quote_regexp = ''"^( {0,4}[>|:#%]| {0,4}[a-z0-9]+[>|]+)+"'';
      send_charset = ''"utf-8:iso-8859-1:us-ascii"'';
      charset = ''"utf-8"'';
      pager_index_lines = "5";
      pager_context = "3";
      pager_stop = "yes";
      menu_scroll = "yes";
      tilde = "yes";
    };

    extraConfig = ''
      mailboxes `find ${config.accounts.email.maildirBasePath} -type d -name cur | sort | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | tr '\n' ' '`

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
      bind index,pager <down> sidebar-next
      bind index,pager <up> sidebar-prev
      bind index,pager <right> sidebar-open
    '';
  };*/
}
