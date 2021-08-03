{ modulesPath, config, pkgs, lib, ... }:

let
  ldap-common-settings = ''
    server_host = ldaps://ldap.lama-corp.space
    server_port = 636
    version = 3
    bind = no
  '';

  # Domains managed by us
  ldap-virtual-mailbox-domains = pkgs.writeText "ldap-virtual-mailbox-domains.cf" ''
    ${ldap-common-settings}
    search_base = ou=domains,dc=lama-corp,dc=space
    query_filter = (&(ObjectClass=dNSDomain)(dc=%s))
    result_attribute = dc
  '';

  ldap-virtual-sender-maps = pkgs.writeText "ldap-virtual-sender-maps.cf" ''
    ${ldap-common-settings}
    search_base = dc=lama-corp,dc=space
    query_filter = (&(objectClass=mailAccount)(|(mailhidden=%s)(mailalias=%s)))
    result_attribute = uid
  '';

  ldap-virtual-mailbox-maps = pkgs.writeText "ldap-virtual-mailbox-maps.cf" ''
    ${ldap-common-settings}
    search_base = dc=lama-corp,dc=space
    query_filter = (&(objectClass=mailAccount)(mailhidden=%s))
    result_attribute = mailhidden
  '';

  ldap-virtual-alias-maps = pkgs.writeText "ldap-virtual-alias-maps.cf" ''
    ${ldap-common-settings}
    search_base = dc=lama-corp,dc=space
    query_filter = (|(&(objectClass=mailAccount)(mailalias=%s))(&(objectClass=mailAlias)(mailalias=%s)))
    result_attribute = maildrop
    special_result_attribute = mailaliasmember, member
    terminal_result_attribute = maildrop
  '';

  certRsa = config.security.acme.certs."${hostname}.rsa".directory;
  certEcc = config.security.acme.certs."${hostname}.ecc".directory;

  hostname = "mail-1.lama-corp.space";

  submissionHeaderCleanupRules = pkgs.writeText "submission_header_cleanup_rules" ''
    /^\s*Received:/                   IGNORE
    /^\s*X-Originating-IP:/           IGNORE
    /^\s*X-Mailer:/                   IGNORE
    /^\s*User-Agent:/                 IGNORE
    /^\s*X-Enigmail:/                 IGNORE
    /^\s*Mime-Version: 1.0.*/         REPLACE Mime-Version: 1.0
    /^\s*Message-ID:\s+<(.*?)@.*?>/  REPLACE Message-ID: <$1@${hostname}>
  '';

  policyd-spf = pkgs.writeText "policyd-spf.conf" ''
    skip_addresses = 172.28.0.0/16,127.0.0.0/8,::ffff:127.0.0.0/104,::1
  '';

  submissionOptions = {
    smtpd_tls_security_level = "encrypt";
    smtpd_sasl_auth_enable = "yes";
    smtpd_sasl_type = "dovecot";
    smtpd_sasl_path = "/run/dovecot2/auth";
    smtpd_sasl_security_options = "noanonymous";
    smtpd_sasl_local_domain = "$myhostname";
    smtpd_client_restrictions = "permit_sasl_authenticated,reject";
    smtpd_sender_restrictions = "reject_sender_login_mismatch";
    smtpd_recipient_restrictions = "reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject";
    cleanup_service_name = "submission-header-cleanup";
  };
in
{
  disabledModules = [
    "services/mail/postfix.nix"
  ];

  imports = [
    ./postfix.lib.nix
  ];

  services.ssmtp.enable = lib.mkForce false;

  networking.firewall.allowedTCPPorts = [
    25
    465
    587
  ];

  security.dhparams.params = {
    "postfix-512".bits = 512;
    "postfix-1024".bits = 1024;
  };

  services.postfix = {
    enable = true;

    # main.cf/myhostname
    # Name of this mail server, used in the SMTP HELO for outgoing mail. Make
    # sure this resolves to the same IP as your reverse DNS hostname.
    inherit hostname;

    # main.cf/mydomain
    domain = "lama-corp.space";

    # main.cf/mydestination
    # Domains for which postfix will deliver local mail. Does not apply to
    # virtual domains, which are configured below. Make sure to specify the
    # FQDN of your sever, as well as localhost.
    # Note: NEVER specify any virtual domains here!!! Those come later.
    destination = [ "localhost" ];

    # main.cf/myorigin
    # Domain appended to mail sent locally from this machine - such as mail sent
    # via the `sendmail` command.
    origin = hostname;

    # mailman
    relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];

    networks = [
      "172.28.0.0/16"
      "127.0.0.0/8"
      "[::ffff:127.0.0.0]/104"
      "[::1]/128"
    ];

    # path to the SSL certificate for the mail server
    # ECC certs are configured in the config section below.
    # main.cf/smtpd_tls_cert_file
    sslCert = "${certRsa}/fullchain.pem";
    # main.cf/smtpd_tls_key_file
    sslKey = "${certRsa}/key.pem";

    useDane = true; # see below

    enableSmtp = true;
    enableSubmission = true;
    enableSubmissions = true;
    inherit submissionOptions;
    submissionsOptions = submissionOptions;

    # master.cf
    masterConfig = {
      smtp = {
        args = [ "-o" "smtp_bind_address=148.251.148.232" ];
      };
      relay = {
        args = [ "-o" "smtp_bind_address=148.251.148.232" ];
      };
      policy-spf = {
        type = "unix";
        privileged = true;
        chroot = false;
        command = "spawn";
        args = [ "user=nobody" "argv=${pkgs.pypolicyd-spf}/bin/policyd-spf" "${policyd-spf}" ];
      };
      "submission-header-cleanup" = {
        type = "unix";
        private = false;
        chroot = false;
        maxproc = 0;
        command = "cleanup";
        args = ["-o" "header_checks=pcre:${submissionHeaderCleanupRules}"];
      };
      postlog = {
        type = "unix-dgram";
        private = false;
        chroot = false;
        maxproc = 1;
        command = "postlogd";
      };
    };

    # main.cf
    config = {
      # disable "new mail" notifications for local unix users
      biff = false;
      append_dot_mydomain = false;

      smtpd_banner = "${hostname} ESMTP NO UCE";

      # prevent spammers from searching for valid users
      disable_vrfy_command = true;

      # require properly formatted email addresses - prevents a lot of spam
      strict_rfc821_envelopes = true;

      # don't give any helpful info when a mailbox doesn't exist
      show_user_unknown_table_name = false;

      # limit maximum e-mail size to 50MB. mailbox size must be at least as big
      # as the message size for the mail to be accepted, but has no meaning
      # after that since we are using Dovecot for delivery.
      message_size_limit = "52428800";
      mailbox_size_limit = "52428800";

      # require addresses of the form "user@domain.tld"
      allow_percent_hack = false;
      swap_bangpath = false;

      # allow plus-aliasing: "user+tag@domain.tld" delivers to "user" mailbox
      recipient_delimiter = "+";

      # IP address used by postfix to send outgoing mail. You only need this if
      # your machine has multiple IP addresses - set it to your MX address to
      # satisfy your SPF record.
      smtp_bind_address = "148.251.148.232";
      # smtp_bind_address6 = "TODO";

      # I have two certificates - one is RSA, the other uses the newer ECC. ECC
      # is faster and arguably more secure, but many mail servers don't yet
      # support it. I enable both types in postfix, but you most likely only
      # have a single RSA cert, and don't need to include these three lines.
      smtpd_tls_eccert_file = "${certEcc}/fullchain.pem";
      smtpd_tls_eckey_file = "${certEcc}/key.pem";
      smtpd_tls_eecdh_grade = "ultra";

      # These two lines define how postfix will connect to other mail servers.
      # DANE is a stronger form of opportunistic TLS. You can read about it
      # here: http://www.postfix.org/TLS_README.html#client_tls_dane
      smtp_tls_security_level = "dane";
      smtp_dns_support_level = "dnssec";
      # DANE requires a DNSSEC capable resolver. If your DNS resolver doesn't
      # support DNSSEC, remove the above two lines and uncomment the below:
      # smtp_tls_security_level = "may";

      # Here we define the options for "mandatory" TLS. In our setup, TLS is
      # only "mandatory" for authenticating users. I got these settings from
      # Mozilla's SSL reccomentations page.
      # NOTE: do not attempt to make TLS mandatory for all incoming/outgoing
      # connections. Do not attempt to change the default cipherlist for non-
      # mandatory connections either. There are still a lot of mail servers out
      # there that do not use TLS, and many that do only support old ciphers.
      # Forcing TLS for everyone *will* cause you to lose mail.

      # This means we only allow TLSv1.2 and TLSv1.3
      smtpd_tls_protocols = "!SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2, TLSv1.3";
      smtp_tls_protocols = "!SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2, TLSv1.3";
      smtpd_tls_mandatory_protocols = "!SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2, TLSv1.3";
      smtp_tls_mandatory_protocols = "!SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2, TLSv1.3";

      # Disable deprecated ciphers
      smtpd_tls_mandatory_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtpd_tls_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtp_tls_mandatory_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtp_tls_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";

      tls_preempt_cipherlist = true;

      smtp_tls_ciphers = "high";
      smtpd_tls_ciphers = "high";
      smtp_tls_mandatory_ciphers = "high";
      smtpd_tls_mandatory_ciphers = "high";

      # allow other mail servers to connect using TLS, but don't require it
      smtpd_tls_security_level = "may";

      # tickets and compression have known vulnerabilities
      # Reduces CPU overhead with `NO_COMPRESSION`, SMTP not at risk of CRIME attack (see git blame for details)
      # Reduce opportunities for a potential CPU exhaustion attack with `NO_RENEGOTIATION`
      tls_ssl_options = "no_ticket, no_compression, no_renegotiation";

      # it's more secure to generate your own DH params
      smtpd_tls_dh512_param_file = config.security.dhparams.params."postfix-512".path;
      smtpd_tls_dh1024_param_file = config.security.dhparams.params."postfix-1024".path;

      # cache incoming and outgoing TLS sessions
      smtpd_tls_session_cache_database = "btree:\${data_directory}/smtpd_tlscache";
      smtp_tls_session_cache_database = "btree:\${data_directory}/smtp_tlscache";

      # only allow authentication over TLS
      smtpd_tls_auth_only = true;
      # Log only a summary message on TLS handshake completion
      smtpd_tls_loglevel = "1";
      # Configure a non blocking source of randomness
      tls_random_source = "dev:/dev/urandom";

      # enable SMTPD auth. Dovecot will place an `auth` socket in postfix's
      # runtime directory that we will use for authentication.
      smtpd_sasl_auth_enable = true;
      smtpd_sasl_path = "/run/dovecot2/auth";
      smtpd_sasl_type = "dovecot";

      # don't allow plaintext auth methods on unencrypted connections
      smtpd_sasl_security_options = "noanonymous, noplaintext";
      # but plaintext auth is fine when using TLS
      smtpd_sasl_tls_security_options = "noanonymous";

      # add a message header when email was recieved over TLS
      smtpd_tls_received_header = true;

      # require that connecting mail servers identify themselves - this greatly
      # reduces spam
      smtpd_helo_required = true;

      # The following block specifies some security restrictions for incoming
      # mail. The gist of it is, authenticated users and connections from
      # localhost can do anything they want. Random people connecting over the
      # internet are treated with more suspicion: they must have a reverse DNS
      # entry and present a valid, FQDN HELO hostname. In addition, they can
      # only send mail to valid mailboxes on the server, and the sender's domain
      # must actually exist.
      smtpd_client_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          reject_unknown_reverse_client_hostname,
          # you might want to consider:
          # reject_unknown_client_hostname,
          # here. This will reject all incoming connections without a reverse DNS
          # entry that resolves back to the client's IP address. This is a very
          # restrictive check and may reject legitimate mail.
          reject_unauth_pipelining
      '';
      smtpd_helo_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          reject_invalid_helo_hostname,
          reject_non_fqdn_helo_hostname,
          # you might want to consider:
          # reject_unknown_helo_hostname,
          # here. This will reject all incoming mail without a HELO hostname that
          # properly resolves in DNS. This is a somewhat restrictive check and may
          # reject legitimate mail.
          reject_unauth_pipelining
      '';
      smtpd_sender_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          reject_non_fqdn_sender,
          reject_unknown_sender_domain,
          reject_unauth_pipelining
      '';
      smtpd_relay_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          # !!! THIS SETTING PREVENTS YOU FROM BEING AN OPEN RELAY !!!
          reject_unauth_destination
          # !!!      DO NOT REMOVE IT UNDER ANY CIRCUMSTANCES      !!!
      '';
      smtpd_recipient_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          reject_non_fqdn_recipient,
          reject_unknown_recipient_domain,
          reject_unauth_pipelining,
          reject_unverified_recipient
      '';
      smtpd_data_restrictions = "\n" + ''
        # this is only for indentation
          permit_mynetworks,
          permit_sasl_authenticated,
          reject_multi_recipient_bounce,
          reject_unauth_pipelining
      '';

      # SPF policy settings
      policy-spf_time_limit = "3600s";

      smtpd_milters = "unix:/run/opendkim/opendkim.sock,unix:/run/rspamd/rspamd-milter.sock";
      non_smtpd_milters = "unix:/run/opendkim/opendkim.sock";
      milter_protocol = "6";
      milter_default_action = "accept";
      milter_mail_macros = "i {mail_addr} {client_addr} {client_name} {auth_type} {auth_authen} {auth_author} {mail_addr} {mail_host} {mail_mailer}";

      # deliver mail for virtual users to Dovecot's LMTP socket
      virtual_transport = "lmtp:unix:/run/dovecot2/dovecot-lmtp";

      # LDAP query to find which domains we accept mail for
      virtual_mailbox_domains = "ldap:${ldap-virtual-mailbox-domains}";
      # LDAP query to find which email addresses we accept mail for
      virtual_mailbox_maps = "ldap:${ldap-virtual-mailbox-maps}";
      smtpd_sender_login_maps = "ldap:${ldap-virtual-sender-maps}";
      # LDAP query to find a user's email aliases
      virtual_alias_maps = "ldap:${ldap-virtual-alias-maps}";

      # PostSRSd
      sender_canonical_maps = "tcp:localhost:10001";
      sender_canonical_classes = "envelope_sender";
      recipient_canonical_maps = "tcp:localhost:10002";
      recipient_canonical_classes= "envelope_recipient,header_recipient";

      # Logs
      maillog_file = "/var/log/mail/postfix.log";
      maillog_file_compressor = "${pkgs.gzip}/bin/gzip";

      # mailman
      transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
      local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
    };
  };

  users.users.postfix.extraGroups = [ "acme" ];
}
