{ lib, ... }:

with lib;

let
  commonEmailAccount = {
    signature.showSignature = "append";
    gpg = {
      key = "marc.schmitt@risson.space";
      encryptByDefault = false;
      signByDefault = true;
    };

    imap = {
      port = 993;
      tls = {
        enable = true;
      };
    };
    smtp = {
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };

    offlineimap = {
      enable = true;
      extraConfig = {
        account = {
          autorefresh = 20;
          quick = 0;
          synclabels = true;
        };
      };
    };
    msmtp.enable = true;
    neomutt.enable = true;
  };

  gmailEmailAccount = {
    flavor = "gmail.com";
  };

  myAccounts = {
    lamacorp = {
      address = "marc.schmitt@lama-corp.space";
      aliases = [
        "risson@lama-corp.space"
        "marc.schmitt@risson.space"
        "risson@risson.space"
      ];
      primary = true;

      realName = "Marc 'risson' Schmitt";
      signature.text = ''
          Marc 'risson' Schmitt
          Lama Corp.
      '';

      userName = "risson";
      passwordCommand = "cat /home/risson/.secrets/mail-lamacorp.passwd";

      smtp.host = "hub.lama-corp.space";
      imap.host = "hub.lama-corp.space";
      folders.inbox = "INBOX";
    };
  };

  extendAccounts = name: value: nameValuePair name (commonEmailAccount // value);
in {
  accounts.email.maildirBasePath = "mail";
  accounts.email.accounts = mapAttrs' extendAccounts myAccounts;

  programs.msmtp.enable = true;

  programs.offlineimap = {
    enable = true;
    extraConfig.general = {
      ui = "basic";
    };
  };

  programs.neomutt = {
    enable = true;
    editor = "\$EDITOR '+set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %s";
    sidebar = {
      enable = true;
    };
  };
}
