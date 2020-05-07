{ ... }:

let port = 19000;
in {
  networking.firewall.allowedTCPPorts = [ port 19001 ];

  services.minio = {
    enable = false; # Enabled by secrets
    listenAddress = ":${toString port}";
    configDir = "/srv/minio/config";
    dataDir = "/srv/minio/data";
  };

  services.nginx = {
    enable = true;
    virtualHosts."tp14.acdc.risson.space.minio-1.vrt.fsn.lama-corp.space" = {
      listen = [
        { addr = "0.0.0.0"; port = 19001; }
        { addr = "[::]"; port = 19001; }
      ];
      locations."/" = {
        proxyPass = "http://localhost:19000/tp14.acdc.risson.space$is_args$args";
      };
    };
  };
}
