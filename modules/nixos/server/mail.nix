{ config, ... }:

{
  services.ssmtp = {
    enable = ! config.services.postfix.enable;
    root = "root@lama-corp.ovh";
    hostName = "ssl0.ovh.net:465";
    useTLS = true;
    domain = with config.networking; "${hostName}.${domain}";
    authUser = "root@lama-corp.ovh";
    authPassFile = "/srv/secrets/root_lama-corp_ovh.passwd";
  };
}
