{ ... }:

let port = 19000;
in {
  networking.firewall.allowedTCPPorts = [ port ];

  services.minio = {
    enable = false; # Enabled by secrets
    listenAddress = ":${toString port}";
    configDir = "/srv/minio/config";
    dataDir = "/srv/minio/data";
  };
}
