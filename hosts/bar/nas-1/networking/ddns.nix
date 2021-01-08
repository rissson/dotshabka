{ config, ... }:

{
  services.ddclient = {
    enable = true;
    configFile = config.sops.secrets.ddns.path;
  };
  systemd.services.ddclient.serviceConfig = {
    CacheDirectory = "ddclient";
    SupplementaryGroups = [ "keys" ];
  };

  sops.secrets.ddns.sopsFile = ./ddns.yml;
}
