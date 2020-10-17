{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ config.services.lighttpd.port ];

  services.lighttpd = {
    enable = true;
    document-root = "/persist/acdc.risson.space";
    extraConfig = ''
      $HTTP["url"] =~ "^/photos($|/)" { server.dir-listing = "enable" }
    '';
  };
}
