{ config, lib, ... }:

with lib;

{
  security.acme.certs = let
    domain = "${config.services.postfix.hostname}";
    extraDomains = { "smtp.lama-corp.space" = null; };
    server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    dnsProvider = "cloudflare";
    credentialsFile = "/srv/secrets/root/acme-dns.keys";
    #postRun = "systemctl restart postfix";
    postRun = "";
  #in mkIf config.services.postfix.enable {
  in {
    "${domain}.rsa" = {
      inherit domain extraDomains dnsProvider credentialsFile postRun;
      inherit server;
      keyType = "rsa4096";
    };
    "${domain}.ecc" = {
      inherit domain extraDomains dnsProvider credentialsFile postRun;
      inherit server;
      keyType = "ec384";
    };
  };

  security.dhparams.params = mkIf config.services.postfix.enable {
    "postfix-512".bits = 512;
    "postfix-1024".bits = 1024;
  };
}
