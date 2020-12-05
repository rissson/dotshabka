{ ... }:

let port = 8003;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."lama-corp.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "/srv/lama-corp.space";
    locations."/".index = "index.html";
  };
}
