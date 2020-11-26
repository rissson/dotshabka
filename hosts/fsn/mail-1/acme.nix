{ config, ... }:

{
  users.users.acme.extraGroups = [ "keys" ];

  security.acme = {
    acceptTerms = true;
    email = "caa@lama-corp.space";
    certs =
      let
        domain = "mail-1.lama-corp.space";
        extraDomainNames = [ "mail.lama-corp.space" ];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.acme_dns_api_key.path;
        postRun = ''
          systemctl reload postfix
          systemctl reload dovecot2
        '';
      in
      {
        "${domain}.rsa" = {
          inherit domain extraDomainNames dnsProvider credentialsFile postRun;
          keyType = "rsa4096";
        };
        "${domain}.ecc" = {
          inherit domain extraDomainNames dnsProvider credentialsFile postRun;
          keyType = "ec384";
        };
      };
  };

  security.dhparams = {
    enable = true;
    defaultBitSize = 2048;
    stateful = true;
    path = "/persist/var/lib/dhparams";
  };

  sops.secrets.acme_dns_api_key = {
    owner = "acme";
    sopsFile = ./acme_dns_api_key.yml;
  };
}
