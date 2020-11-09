{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 8200 ];
  services.vault = {
    enable = true;
    package = pkgs.vault-bin; # includes web interface
    address = "172.29.1.2:8200";
    storagePath = "/persist/vault";
    storageBackend = "file";
    extraConfig = ''
      ui = true
      api_addr = "http://172.29.1.2:8200"
      cluster_addr = "https://127.0.0.1:8200"
    '';
  };
}
