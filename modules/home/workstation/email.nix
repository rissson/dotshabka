{ config, lib, pkgs, ... }:

{
  accounts.email.accounts = {
    "marcschmitt2@gmail.com" = {
      address = "marcschmitt2@gmail.com";
      flavor = "gmail.com";
      gpg = {
        key = "0xF6FD87B15C263EC9";
        signByDefault = true;
        encryptByDefault = false;
      };
      imap = {
        host = "mail.google.com";
        port = 993;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };
      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        onNotify = "${pkgs.isync}/bin/mbsync test-%s";
        onNotifyPost = {
          mail = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
        };
      };
      mbsync = {
        enable = true;
      };
      msmtp = {
        enable = true;
      };
      neomutt = {
        enable = true;
      };
      notmuch.enable = true;
      offlineimap = {
        enable = true;
      };
      passwordCommand = "echo lol";
      primary = true;
      realName = "Marc 'risson' Schmitt";
      signature = {
        showSignature = "append";
        text = ''
          --
          Marc 'risson' Schmitt
        '';
      };
      smtp = {
        host = "smtp.google.com";
        port = 465;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };
      userName = "marcschmitt2@gmail.com";
    };
  };
}
