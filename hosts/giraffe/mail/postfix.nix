{ config, ... }:

{
  services.postfix = {
    # main.cf
    config = {
      # "2" is current for postfix 3.2 configs
      compatibility_level = 2;

      # disable "new mail" notifications for local unix users
      biff = "no";

      # Name of this mail server, used in the SMTP HELO for outgoing mail. Make
      # sure this resolves to the same IP as your reverse DNS hostname.
      myhostname = "${config.networking.hostName}.${config.networking.domain}";

      # Domains for which postfix will deliver local mail. Does not apply to
      # virtual domains, which are configured below. Make sure to specify the FQDN
      # of your sever, as well as localhost.
      # Note: NEVER specify any virtual domains here!!! Those come later.
      mydestination = "$myhostname";

      smtpd_recipient_restrictions = "permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination";
      relay_domains = "$mydestination, lama-corp.space";
      relay_recipient_maps = "";
    };
  };
}
