{ config, lib, ... }:

with lib;

{
  services.clamav = mkIf config.services.rspamd.enable {
    daemon.enable = true;
    updater.enable = true;

    daemon.extraConfig = ''
      PhishingScanURLs no
    '';
  };
}
