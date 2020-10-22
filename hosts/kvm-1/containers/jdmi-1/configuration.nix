{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts."jdmi.risson.space" = {
      root = "/persist/jdmi.risson.space/site";
      locations."/".index = "index.html";
    };
  };
}
