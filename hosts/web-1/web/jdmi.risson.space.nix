{ ... }:

let port = 8002;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."jdmi.risson.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "/srv/jdmi.risson.space/site";
    locations."/".index = "index.html";
  };
}
