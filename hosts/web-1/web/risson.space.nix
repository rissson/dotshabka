{ ... }:

let port = 8004;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."risson.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "/srv/risson.space/prod";
    locations."/".index = "index.html";
  };
}
