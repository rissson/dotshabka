{ config, lib, pkgs, ... }:

with lib;

let
  dataDir = "/srv/mail";

  ldap-conf-ext = pkgs.writeText "ldap.conf.ext" ''
    hosts = ldap-1.duck.srv.fsn.lama-corp.space
    ldap_version = 3
    auth_bind = yes
    auth_bind_userdn = uid=%n,ou=users,dc=lama-corp,dc=space
    base = dc=lama-corp,dc=space
    deref = never
    scope = subtree
    user_attrs =
    user_filter = (&(objectclass=inetOrgPerson)(uid=%n)(memberOf=cn=mail,ou=permissions,dc=lama-corp,dc=space))
    pass_filter = (&(objectclass=inetOrgPerson)(uid=%n)(memberOf=cn=mail,ou=permissions,dc=lama-corp,dc=space))
    default_pass_scheme = CRYPT
  '';

in {
  security.acme.certs = mkIf config.services.dovecot2.enable {
    "imap.lama-corp.space" = {
      extraDomains = { "imap-1.lama-corp.space" = null; };
      dnsProvider = "cloudflare";
      credentialsFile = "/srv/secrets/acme/dns-credentials";
      postRun = "systemctl reload dovecot2";
    };
  };

  services.dovecot2 = rec {
    enable = true;
    modules = [ pkgs.dovecot_pigeonhole ];

    mailUser = "vmail";
    mailGroup = "vmail";

    enableImap = true;
    enableLmtp = true;

    protocols = [ "sieve" ];

    enablePAM = false;

    # directory to store mail. The tilda makes it relative to the *dovecot*
    # virtual home directory.
    #
    # We use mdbox - this is Dovecot's own high-performance mail store format.
    # There are other slower, more "traditional" formats you can choose from.
    # Read about them here: https://wiki2.dovecot.org/MailboxFormat
    mailLocation = "maildir:${dataDir}/vhosts/%n:LAYOUT=fs";

    sslCACert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    sslServerCert = "${
        config.security.acme.certs."imap.lama-corp.space".directory
      }/fullchain.pem";
    sslServerKey =
      "${config.security.acme.certs."imap.lama-corp.space".directory}/key.pem";

    mailboxes = [
      {
        name = "Drafts";
        auto = "subscribe";
        specialUse = "Drafts";
      }
      {
        name = "Junk";
        auto = "create";
        specialUse = "Junk";
      }
      {
        name = "Trash";
        auto = "create";
        specialUse = "Trash";
      }
      {
        name = "Archive";
        auto = "subscribe";
        specialUse = "Archive";
      }
      {
        name = "Sent";
        auto = "subscribe";
        specialUse = "Sent";
      }
    ];

    sieveScripts = {
      after = builtins.toFile "spam.sieve" ''
        require "fileinto";

        if header :is "X-Spam" "Yes" {
            fileinto "Junk";
            stop;
        }
      '';
    };

    extraConfig = concatStrings [
      # authentication
      ''
        # cache all authentication results for one hour
        auth_cache_size = 10M
        auth_cache_ttl = 1 hour
        auth_cache_negative_ttl = 1 hour

        # passdb specifies how users are authenticated - LDAP in our case
        passdb {
          driver = ldap
          args = ${ldap-conf-ext}
        }

        # userdb specifies the location of users' "home" directories - where their
        # mail is stored. e.g. /var/mail/vhosts/exmaple.com/user
        # %d = domain, %n = user
        userdb {
          driver = static
          args = uid=vmail gid=vmail home=${dataDir}/vhosts/%n
        }
      ''

      # mail
      ''

        # default home directory location for all users
        mail_home = ${dataDir}/vhosts/%n;

        namespace inbox {
          separator = /
          inbox = yes
        }

        # set this to the group that owns your vmail directory.
        mail_privileged_group = ${mailUser}

        # these lines enable attachment deduplication. Attachments must be somewhat
        # large (64k) to store them separately from the mail store.
        mail_attachment_dir = ${dataDir}/attachments
        mail_attachment_min_size = 64k

        recipient_delimiter = +
        lmtp_save_to_detail_mailbox = yes
      ''

      # master
      ''
        # to improve performance, disable fsync globally - we will enable it for
        # some specific services later on
        mail_fsync = never

        service imap-login {
          # plain-text IMAP should only be accessible from localhost
          inet_listener imap {
            address = 127.0.0.1, ::1
          }

          # enable high-performance mode, described here:
          # https://wiki.dovecot.org/LoginProcess
          service_count = 0
          # set to the number of CPU cores on your server
          process_min_avail = 4
          vsz_limit = 1G
        }

        # disable POP3 altogether
        service pop3-login {
          inet_listener pop3 {
            port = 0
          }
          inet_listener pop3s {
            port = 0
          }
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
            group = postfix
            mode = 0600
            user = postfix
          }
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

      # SSL/TLS
      ''
        ssl = required
        ssl_min_protocol = TLSv1.2
        ssl_cipher_list = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
        ssl_prefer_server_ciphers = yes
      ''

      # LDA
      ''
        # configuration for mail delivered by the `dovecot-lda` command.
        # Shouldn't be needed since we are using LMTP, but kept for backwards
        # compatibility.
        protocol lda {
          # use fsync for write-safety - this deals with delivering actual mail
          mail_fsync = optimized
          mail_plugins = $mail_plugins sieve
        }

        lda_mailbox_autosubscribe = yes
        lda_mailbox_autocreate = yes
      ''

      # IMAP
      ''
        protocol imap {
          # max IMAP connections per IP address
          mail_max_userip_connections = 50
          # imap_sieve will be used for spam training by rspamd
          mail_plugins = $mail_plugins imap_sieve
        }
      ''

      # LMTP
      ''
        protocol lmtp {
          # use fsync for write-safety - this deals with delivering actual mail
          mail_fsync = optimized
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
          # location of users' sieve directory and their "active" sieve script
          sieve = file:~/sieve;active=~/.dovecot.sieve

          # directory of global sieve scripts to run before and after processing
          # ALL incoming mail
          sieve_before = ${dataDir}/sieve/before
          sieve_after = ${dataDir}/sieve/after

          # make sieve aware of user+tag@domain.tld aliases
          recipient_delimiter = +

          # maximum size of all user's sieve scripts
          sieve_quota_max_storage = 50M
        }
      ''
    ];
  };
}
