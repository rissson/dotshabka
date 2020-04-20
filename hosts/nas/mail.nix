{ config, ... }:

{
  services.ssmtp = {
    enable = true;
    root = "root@lama-corp.ovh";
    hostName = "ssl0.ovh.net:465";
    useTLS = true;
    domain = "${config.networking.hostName}.${config.networking.domain}";
    authUser = "root@lama-corp.ovh";
    authPassFile = "/srv/secrets/root_lama-corp_ovh.passwd";
  };
}
