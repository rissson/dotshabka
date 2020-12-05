{ ... }:

let port = 8000;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."acdc.risson.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "/srv/acdc.risson.space";
    locations = {
      "/photos" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
