{ config, pkgs, lib, ... }:

let
  ldap-conf-ext = pkgs.writeText "ldap.conf.ext" ''
    hosts = ldap.k8s.fsn.lama-corp.space
    ldap_version = 3
    auth_bind = yes
    auth_bind_userdn = uid=%n,ou=users,dc=lama-corp,dc=space
    base = dc=lama-corp,dc=space
    deref = never
    scope = subtree
    user_attrs =
    user_filter = (&(objectClass=mailAccount)(uid=%n))
    pass_filter = (&(objectClass=mailAccount)(uid=%n))
    default_pass_scheme = CRYPT
  '';

  certRsa = config.security.acme.certs."${hostname}.rsa".directory;

  hostname = "mail-1.lama-corp.space";

  mailDir = "/var/vmail";
  stateDir = "/var/lib/dovecot";

  pipeBin = pkgs.stdenv.mkDerivation {
    name = "pipe_bin";
    src = ./dovecot/pipe_bin;
    buildInputs = with pkgs; [ makeWrapper coreutils bash rspamd ];
    buildCommand = ''
      mkdir -p $out/pipe/bin
      cp $src/* $out/pipe/bin/
      chmod a+x $out/pipe/bin/*
      patchShebangs $out/pipe/bin

      for file in $out/pipe/bin/*; do
        wrapProgram $file \
          --set PATH "${pkgs.coreutils}/bin:${pkgs.rspamd}/bin"
      done
    '';
  };
in
{
  networking.firewall.allowedTCPPorts = [
    143
    993
    4190
  ];

  services.dovecot2 = rec {
    enable = true;
    modules = [ pkgs.dovecot_pigeonhole ];

    mailUser = "vmail";
    mailGroup = "vmail";

    enableImap = true;
    enableLmtp = true;
    enablePAM = false;

    protocols = [ "sieve" ];

    mailLocation = "maildir:~/Maildir:LAYOUT=fs";

    sslServerCert = "${certRsa}/fullchain.pem";
    sslServerKey = "${certRsa}/key.pem";

    mailboxes = {
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Junk = {
        auto = "create";
        specialUse = "Junk";
      };
      Trash = {
        auto = "create";
        specialUse = "Trash";
      };
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
    };

    sieveScripts = {
      after = pkgs.writeText "spam.sieve" ''
        require "fileinto";

        if header :is "X-Spam" "Yes" {
          fileinto "Junk";
          stop;
        }
      '';
    };

    extraConfig = lib.concatStrings [
      # imap
      ''
        # disable POP3 altogether
        service pop3-login {
          inet_listener pop3 {
            port = 0
          }
          inet_listener pop3s {
            port = 0
          }
        }

        service imap-login {
          inet_listener imap {
            address = 127.0.0.1, ::1
            port = 143
          }
          inet_listener imaps {
            port = 993
            ssl = yes
          }

          # enable high-performance mode, described here:
          # https://wiki.dovecot.org/LoginProcess
          service_count = 0
          # set to the number of CPU cores on your server
          process_min_avail = 2
          vsz_limit = 1G
        }

        protocol imap {
          mail_max_userip_connections = 100
          mail_plugins = $mail_plugins imap_sieve
        }

        # enable semi-long-lived IMAP processes to improve performance
        service imap {
          service_count = 256
          # set to the number of CPU cores on your server
          process_min_avail = 4
        }

        # expose an LMTP socket for postfix to deliver mail
        service lmtp {
          unix_listener dovecot-lmtp {
            mode = 0600
            user = ${config.services.postfix.user}
            group = ${config.services.postfix.group}
          }
        }
      ''

      # authentication
      ''
        auth_mechanisms = plain login

        # cache all authentication for one hour
        auth_cache_size = 10M
        auth_cache_ttl = 1 hour
        auth_cache_negative_ttl = 1 hour

        # passdb specifies how users are authenticated - LDAP in our case
        passdb {
          driver = ldap
          args = ${ldap-conf-ext}
        }

        # userdb specifies the location of users' "home" directories - where
        # their mail is stored. e.g. /var/mail/vhosts/exmaple.com/user
        # %d = domain, %n = user
        userdb {
          driver = static
          args = uid=vmail gid=vmail home=${mailDir}/%n
        }

        # expose an auth socket for postfix to authenticate users
        service auth {
          unix_listener auth {
            mode = 0660
            user = ${config.services.postfix.user}
            group = ${config.services.postfix.group}
          }
        }

        # no need to run this as root
        service auth-worker {
          user = ${mailUser}
        }
      ''

      # mail
      ''
        namespace inbox {
          separator = /
          inbox = yes
        }

        # set this to the group that owns your vmail directory.
        mail_privileged_group = ${mailGroup}
        mail_access_groups = ${mailGroup}

        # these lines enable attachment deduplication. Attachments must be
        # somewhat large (64k) to store them separately from the mail store.
        mail_attachment_dir = ~/attachments
        mail_attachment_min_size = 64k

        recipient_delimiter = +
        lmtp_save_to_detail_mailbox = no
      ''

      # SSL/TLS
      ''
        ssl = required
        ssl_min_protocol = TLSv1.2
        ssl_cipher_list = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl_prefer_server_ciphers = no
      ''

      # LDA
      ''
        # configuration for mail delivered by the `dovecot-lda` command.
        # Shouldn't be needed since we are using LMTP, but kept for backwards
        # compatibility.
        protocol lda {
          mail_plugins = $mail_plugins sieve
        }

        lda_mailbox_autosubscribe = yes
        lda_mailbox_autocreate = yes
      ''

      # LMTP
      ''
        protocol lmtp {
          mail_plugins = $mail_plugins sieve
        }
      ''

      # managesieve
      ''
        protocols = $protocols sieve
        # remote managesieve functionality
        service managesieve-login {
          inet_listener sieve_deprecated {
            port = 0
          }
          service_count = 0
          process_min_avail = 4
          vsz_limit = 1G
        }
      ''

      # sieve
      ''
        plugin {
          sieve_plugins = sieve_imapsieve sieve_extprograms

          # location of users' sieve directory and their "active" sieve script
          sieve = file:~/sieve;active=~/.dovecot.sieve
          sieve_default = file:~/default.sieve
          sieve_default_name = default

          # make sieve aware of user+tag@domain.tld aliases
          recipient_delimiter = +

          # maximum size of all user's sieve scripts
          sieve_quota_max_storage = 50M

          # From elsewhere to Spam folder
          imapsieve_mailbox1_name = Junk
          imapsieve_mailbox1_causes = COPY
          imapsieve_mailbox1_before = file:${stateDir}/imap_sieve/report-spam.sieve

          # From Spam folder to elsewhere
          imapsieve_mailbox2_name = *
          imapsieve_mailbox2_from = Junk
          imapsieve_mailbox2_causes = COPY
          imapsieve_mailbox2_before = file:${stateDir}/imap_sieve/report-ham.sieve

          sieve_pipe_bin_dir = ${pipeBin}/pipe/bin

          sieve_global_extensions = +vnd.dovecot.pipe +vnd.dovecot.environment
        }
      ''
    ];
  };

  systemd.services.dovecot2 = {
    preStart = ''
      rm -rf "${stateDir}/imap_sieve"
      mkdir -p "${stateDir}/imap_sieve"
      cp -p "${./dovecot/imap_sieve}"/* "${stateDir}/imap_sieve"
      for k in "${stateDir}/imap_sieve"/*.sieve; do
        ${pkgs.dovecot_pigeonhole}/bin/sievec "$k"
      done
      chown -R "${config.services.dovecot2.mailUser}:${config.services.dovecot2.mailGroup}" "${stateDir}/imap_sieve"
    '';
  };

  systemd.services.postfix = {
    after = [ "dovecot2.service" ];
    requires = [ "dovecot2.service" ];
  };

  users.users.dovecot2.extraGroups = [ "acme" ];
}
