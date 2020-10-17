{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts."acdc.risson.space" = {
      root = "/persist/acdc.risson.space";
      locations = {
        "/photos" = {
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}
