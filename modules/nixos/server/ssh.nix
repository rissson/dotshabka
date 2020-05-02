{ config, lib, ... }:

with lib;

{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/srv/ssh/ssh_host_rsa_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
      {
        type = "ed25519";
        path = "/srv/ssh/ssh_host_ed25519_key";
        rounds = 100;
        openSSHFormat = true;
        comment = with config.networking; "${hostName}.${domain}";
      }
    ];

    extraConfig = ''
      Match Address 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,169.254.0.0/16,fe80::/10,fd00::/8
        PermitRootLogin prohibit-password
    '';
  };

  systemd.services.sshd.preStart = mkBefore ''
    mkdir -m 0755 -p /srv/ssh
  '';
}
