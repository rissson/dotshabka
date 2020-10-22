{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts."lama-corp.space" = {
      root = "/persist/lama-corp.space";
      locations."/".index = "index.html";
    };
  };
}
